//
//  MessengerSession.swift
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

import WatchConnectivity

open class MessengerSession: NSObject {

    private var session: WCSession!
    private var messenger: Messenger!
    public static let shared = MessengerSession()

    private override init() {
        super.init()
        messenger = Messenger(withApplicationGroupIdentifier: nil, directory: nil)
        session = WCSession.default
        session.delegate = self
    }

    open func activateSession() {
        session.activate()
    }

    open func notifyListenerForMessage(withIdentifier identifier: String?, message: Any?) {
        messenger.notifyListenerForMessage(withIdentifier: identifier, message: message)
    }

    open func passMessage(message: Any?, identifier: String?) {
        messenger.passMessage(message: message, identifier: identifier)
    }

    open func messageForIdentifier(identifier: String?) -> Any? {
        return messenger.messageForIdentifier(identifier: identifier)
    }

    open func clearMessageContents(identifer: String?) {
        messenger.clearMessageContents(identifer: identifer)
    }

    open func clearAllMessageContents() {
        messenger.clearAllMessageContents()
    }

    open func listenForMessage(withIdentifier identifier: String?, listener: @escaping ((Any) -> Void)) {
        messenger.listenForMessage(withIdentifier: identifier, listener: listener)
    }

    open func stopListeningForMessage(withIdentifier identifier: String?) {
        messenger.stopListeningForMessage(withIdentifier: identifier)
    }

}

extension MessengerSession: WCSessionDelegate {

    @available(watchOSApplicationExtension 2.2, *)
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {

    }
    #endif

    #if os(iOS)
    public func sessionDidDeactivate(_ session: WCSession) {

    }
    #endif

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        for identifier in message.keys {
            if let data = message[identifier] as? Data {
                let message = NSKeyedUnarchiver.unarchiveObject(with: data)
                messenger.notifyListenerForMessage(withIdentifier: identifier, message: message)
            }
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        for identifier in applicationContext.keys {
            if let data = applicationContext[identifier] as? Data {
                let message = NSKeyedUnarchiver.unarchiveObject(with: data)
                messenger.notifyListenerForMessage(withIdentifier: identifier, message: message)
            }
        }
    }

    public func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let identifier =  file.metadata?["identifier"] as? String else {
            return
        }
        do {
            let data = try NSData(contentsOf: file.fileURL) as Data
            guard let message = NSKeyedUnarchiver.unarchiveObject(with: data) else {
                return
            }
            messenger.notifyListenerForMessage(withIdentifier: identifier, message: message)
            let messengerFileTransiting = messenger.transitingDelegate as? MessengerFileTransiting
            let archivedData = NSKeyedArchiver.archivedData(withRootObject: message) as NSData
            guard let filePath = messengerFileTransiting?.filePath(forIdentifier: identifier) else {
                return
            }
            archivedData.write(to: URL(fileURLWithPath: filePath), atomically: true)
        } catch let error as NSError {
            NSLog("SwiftyMessenger: Error on didReceive file \(error.description)")
        }
    }

}
