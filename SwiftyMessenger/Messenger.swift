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
            break
        case .sessionContext:
            transitingDelegate = MessengerSessionContextTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
            break
        case .sessionFile:
            transitingDelegate = MessengerSessionFileTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
            break
        case .sessionMessage:
            transitingDelegate = MessengerSessionMessageTransiting(withApplicationGroupIdentifier: identifier, directory: directory)
            break
        }
    }

    @objc private func didReceiveMessageNotification(notification: Notification) {

    }

    open func notifyListenerForMessage(withIdentifier identifier: String?, message: Any?) {

    }

}
