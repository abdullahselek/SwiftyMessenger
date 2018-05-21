//
//  MessengerCoordinatedFileTransiting.swift
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
  This class inherits from the default implementation of the FileTransiting protocol
  and implements message transiting in a similar way but using FileCoordinator for its file
  reading and writing.
 */
open class MessengerCoordinatedFileTransiting: MessengerFileTransiting {

    open var additionalFileWritingOptions: NSData.WritingOptions!

    override func writeMessage(message: Any?, identifier: String) -> Bool {
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
        let fileURL = URL(fileURLWithPath: filePath)
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?
        var success = false
        fileCoordinator.coordinate(readingItemAt: fileURL, options: NSFileCoordinator.ReadingOptions(rawValue: 0), error: &error) { newURL in
            do {
                try data.write(to: newURL, options: [.atomic, additionalFileWritingOptions])
                success = true
            } catch let error as NSError {
                print("SwiftyMessenger: Error on writeMessage \(error.description)")
                success = false
            }
        }
        return success
    }

}
