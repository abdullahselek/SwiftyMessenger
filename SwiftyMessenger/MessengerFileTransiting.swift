//
//  MessengerFileTransiting.swift
//  SwiftyMessenger
//
//  Copyright © 2018 Abdullah Selek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

/**
  Interface for classes wishing to support the transiting of data
  between container app and extension. Transiting is defined as passage between two points, and in this
  case it involves both the reading and writing of messages as well as the deletion of message
  contents.
 */
internal protocol FileTransiting {

    /**
      Responsible for writing a given message object in a persisted format for a given
      identifier. The method should return true if the message was successfully saved. The message object
      may be nil, in which case true should also be returned. Returning true from this method results in a
      notification being fired which will trigger the corresponding listener block for the given
      identifier.

      - parameter message: The message dictionary to be passed.
      This dictionary may be nil. In this the method should return true.
      - parameter identifier: The identifier for the message
      - return: `true` indicating that a notification should be sent and `false` otherwise
     */
    func writeMessage(message: Any?, identifier: String) -> Bool

    /**
      For reading and returning the contents of a given message. It should
      understand the structure of messages saved by the implementation of the above writeMessage
      method and be able to read those messages and return their contents.

      - parameter identifier: The identifier for the message
      - return: Optional message object
     */
    func messageForIdentifier(identifier: String?) -> Any?

    /**
      Clear the persisted contents of a specific message with a given identifier.

      - parameter identifier: The identifier for the message
     */
    func deleteContent(withIdentifier identifier: String?)

    /**
      Clear the contents of all messages passed to the Messenger.
     */
    func deleteContentForAllMessages()

}

/**
  Protocol used to notify container app and extension with identifier and message.
 */
internal protocol TransitingDelegate {

    /**
      Notifier between two sides.

      - parameter identifier: The identifier for the message
      - parameter message: Message dictionary
     */
    func notifyListenerForMessage(withIdentifier identifier: String?, message: Any?)

}

class MessengerFileTransiting: FileTransiting {

    internal var applicationGroupIdentifier: String!
    internal var directory: String?
    internal var fileManager: FileManager!

    internal convenience init() {
        self.init(withApplicationGroupIdentifier: "dev.messenger.nonDesignatedInitializer", directory: nil)
    }

    /**
     Initializer.

     - parameter identifier: An application group identifier
     - parameter directory: An optional directory to read/write messages
     */
    init(withApplicationGroupIdentifier identifier: String, directory: String?) {
        applicationGroupIdentifier = identifier
        self.directory = directory
        fileManager = FileManager()
        checkAppGroupCapabilities(applicationGroupIdentifier: applicationGroupIdentifier)
    }

    private func checkAppGroupCapabilities(applicationGroupIdentifier: String) {
        if (NSClassFromString("XCTest") == nil) {
            assert(fileManager.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier) != nil, "App Group Capabilities may not be correctly configured for your project, or your appGroupIdentifier may not match your project settings. Check Project->Capabilities->App Groups. Three checkmarks should be displayed in the steps section, and the value passed in for your appGroupIdentifier should match the setting in your project file.")
        }
    }
    
    // MARK: File Operation Methods

    internal func messagePassingDirectoryPath() -> String? {
        guard let appGroupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier) else {
            return nil
        }
        let appGroupContainerPath = appGroupContainer.path
        var directoryPath = appGroupContainerPath
        if let directory = directory {
            directoryPath = appGroupContainerPath.appending(directory)
        }
        do {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("SwiftyMessenger: Error on messagePassingDirectoryPath \(error.description)")
            return nil
        }
        return directoryPath
    }

    internal func filePath(forIdentifier identifier: String) -> String? {
        if identifier.isEmpty {
            return nil
        }
        let directoryPath = messagePassingDirectoryPath()
        let fileName = String(format: "%@.archive", identifier)
        let filePath = directoryPath?.appending(fileName)
        return filePath
    }

    // MARK: FileTransiting

    func writeMessage(message: Any?, identifier: String) -> Bool {
        if identifier.isEmpty {
            return false
        }
        guard let message = message else {
            return false
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: message) as NSData
        guard let filePath = self.filePath(forIdentifier: identifier) else {
            return false
        }
        let success = data.write(toFile: filePath, atomically: true)
        if !success {
            return false
        }
        return true
    }

    func messageForIdentifier(identifier: String?) -> Any? {
        guard let identifier = identifier else {
            return nil
        }
        guard let filePath = self.filePath(forIdentifier: identifier) else {
            return nil
        }
        do {
            let data = try NSData(contentsOfFile: filePath) as Data
            let message = NSKeyedUnarchiver.unarchiveObject(with: data)
            return message
        } catch let error as NSError {
            print("SwiftyMessenger: Error on messageForIdentifier \(error.description)")
            return nil
        }
    }

    func deleteContent(withIdentifier identifier: String?) {
        guard let identifier = identifier else {
            print("SwiftyMessenger: Can't delete content, given identifier is nil")
            return
        }
        do {
            try fileManager.removeItem(atPath: identifier)
        } catch let error as NSError {
            print("SwiftyMessenger: Error on deleteContent \(error.description)")
        }
    }

    func deleteContentForAllMessages() {
        guard let _ = directory, let directoryPath = messagePassingDirectoryPath() else {
            return
        }
        do {
            let messageFiles = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for path in messageFiles {
                let filePath = directoryPath.appending(path)
                do {
                    try fileManager.removeItem(atPath: filePath)
                } catch let error as NSError {
                    print("SwiftyMessenger: Error on deleteContentForAllMessages \(error.description)")
                }
            }
        } catch let error as NSError {
            print("SwiftyMessenger: Error on deleteContentForAllMessages \(error.description)")
        }
    }

}
