//
//  Messenger.swift
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

import CoreFoundation

public enum TransitingType {
    case file
    case coordinatedFile
    case sessionContext
    case sessionMessage
    case sessionFile
}

/**
  Creates a connection between a containing iOS application and an extension. Used to pass data or
  commands back and forth between the two locations.
 */
open class Messenger: TransitingDelegate {

    open var transitingDelegate: FileTransiting?
    private var listenerBlocks = [String: (Any) -> Void]()
    private static let NotificationName = NSNotification.Name(rawValue: "MessengerNotificationName")

    public init(withApplicationGroupIdentifier identifier: String, directory: String?) {
        transitingDelegate = MessengerFileTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Messenger.didReceiveMessageNotification(notification:)),
                                               name: Messenger.NotificationName,
                                               object: self)
    }

    public convenience init(withApplicationGroupIdentifier identifier: String,
                            directory: String?,
                            transitingType: TransitingType) {
        self.init(withApplicationGroupIdentifier: identifier, directory: directory)
        switch transitingType {
        case .file:
            break
        case .coordinatedFile:
            transitingDelegate = MessengerCoordinatedFileTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
        case .sessionContext:
            transitingDelegate = MessengerSessionContextTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
        case .sessionFile:
            transitingDelegate = MessengerSessionFileTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
        case .sessionMessage:
            transitingDelegate = MessengerSessionMessageTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
        }
    }

    private func notificationCallBack(observer: UnsafeMutableRawPointer, identifier: String) {
        NotificationCenter.default.post(name: Messenger.NotificationName, object:observer, userInfo: ["identifier": identifier])
    }

    private func registerForNotification(withIdentifier identifier: String) {
        unregisterForNotification(withIdentifier: identifier)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        let str = identifier as CFString
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(notificationCenter, observer, {
            (notificationCenter, observer, notificationName, rawPointer, dictionary)  -> Void in
            if let observer = observer, let notificationName = notificationName {
                let mySelf = Unmanaged<Messenger>.fromOpaque(observer).takeUnretainedValue()
                mySelf.notificationCallBack(observer: observer, identifier: notificationName.rawValue as String)
            }
        }, str, nil, .deliverImmediately)
    }

    private func unregisterForNotification(withIdentifier identifier: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        let str = identifier as CFString
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(notificationCenter, observer, CFNotificationName(str), nil)
    }

    @objc private func didReceiveMessageNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let identifier = userInfo["identifier"] as? String else {
            return
        }
        let message = transitingDelegate?.messageForIdentifier(identifier: identifier)
        notifyListenerForMessage(withIdentifier: identifier, message: message)
    }

    open func notifyListenerForMessage(withIdentifier identifier: String?, message: Any?) {
        guard let identifier = identifier, let message = message else {
            return
        }
        guard let listenerBlock = listenerBlock(forIdentifier: identifier) else {
            return
        }
        DispatchQueue.main.async {
            listenerBlock(message)
        }
    }

    private func listenerBlock(forIdentifier identifier: String) -> ((Any) -> Void)? {
        return listenerBlocks[identifier]
    }

    private func sendNotification(forMessageIdentifier identifier: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        let deliverImmediately = true
        let str = identifier as CFString
        CFNotificationCenterPostNotification(notificationCenter, CFNotificationName(str), nil, nil, deliverImmediately)
    }

    /**
      Passes a message associated with a given identifier. This is the primary means
      of passing information through the messenger.
     */
    open func passMessage(message: Any?, identifier: String?) {
        guard let identifier = identifier else {
            return
        }
        if transitingDelegate?.writeMessage(message: message, identifier: identifier) == true {
            sendNotification(forMessageIdentifier: identifier)
        }
    }

    /**
      Returns the value of a message with a specific identifier as an object.
     */
    open func messageForIdentifier(identifier: String?) -> Any? {
        return transitingDelegate?.messageForIdentifier(identifier: identifier)
    }

    /**
      Clears the contents of a specific message with a given identifier.
     */
    open func clearMessageContents(identifer: String?) {
        transitingDelegate?.deleteContent(withIdentifier: identifer)
    }

    /**
      Clears the contents of your optional message directory to give you a clean state.
     */
    open func clearAllMessageContents() {
        transitingDelegate?.deleteContentForAllMessages()
    }

    /**
      Begins listening for notifications of changes to a message with a specific identifier.
      If notifications are observed then the given listener block will be called along with the actual
      message.
     */
    open func listenForMessage(withIdentifier identifier: String?, listener: @escaping ((Any) -> Void)) {
        guard let identifier = identifier else {
            return
        }
        listenerBlocks[identifier] = listener
        registerForNotification(withIdentifier: identifier)
    }

    /**
      Stops listening for change notifications for a given message identifier.
     */
    open func stopListeningForMessage(withIdentifier identifier: String?) {
        guard let identifier = identifier else {
            return
        }
        listenerBlocks[identifier] = nil
        unregisterForNotification(withIdentifier: identifier)
    }

}
