//
//  MessengerSessionContextTransiting.swift
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

/**
  Provides support for the WatchConnectivity framework's Application Context message
  reading and writing ability. This class will pass it's messages directly via the
  -updateApplicationContext method, and read message values from application context.
 */
class MessengerSessionContextTransiting: MessengerFileTransiting {

    private var session: WCSession!
    private var lastContext: [String: Any]?

    override init(withApplicationGroupIdentifier identifier: String, directory: String?) {
        super.init(withApplicationGroupIdentifier: identifier, directory: directory)
        session = WCSession.default
    }

    override func writeMessage(message: Any?, identifier: String) -> Bool {
        if identifier.isEmpty {
            return false
        }
        if !WCSession.isSupported() {
            return false
        }
        guard let message = message else {
            return false
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: message) as Data
        let applicationContext = session.applicationContext
        if lastContext == nil {
            lastContext = applicationContext
        }
        var currentContext = applicationContext
        applicationContext.forEach { (arg) in
            let (key, value) = arg
            currentContext[key] = value
        }
        currentContext[identifier] = data
        lastContext = currentContext
        do {
            try session.updateApplicationContext(currentContext)
        } catch let error as NSError {
            print("SwiftyMessenger: Error on writeMessage \(error.description)")
        }
        return false
    }

    override func messageForIdentifier(identifier: String?) -> Any? {
        guard let identifier = identifier else {
            return nil
        }
        let receivedContext = session.receivedApplicationContext
        guard let data = receivedContext[identifier] as? Data else {
            let currentContext = session.applicationContext
            guard let dataFromContext = currentContext[identifier] as? Data else {
                return nil
            }
            let message = NSKeyedUnarchiver.unarchiveObject(with: dataFromContext)
            return message
        }
        let message = NSKeyedUnarchiver.unarchiveObject(with: data)
        return message
    }

    override func deleteContent(withIdentifier identifier: String?) {
        guard let identifier = identifier, var lastContext = lastContext else {
            return
        }
        lastContext[identifier] = nil
        var currentContext = session.applicationContext
        currentContext[identifier] = nil
        do {
            try session.updateApplicationContext(currentContext)
        } catch let error as NSError {
            print("SwiftyMessenger: Error on deleteContent \(error.description)")
        }
    }

    override func deleteContentForAllMessages() {
        guard var lastContext = lastContext else {
            return
        }
        lastContext.removeAll()
        do {
            try session.updateApplicationContext([String: Any]())
        } catch let error as NSError {
            print("SwiftyMessenger: Error on deleteContentForAllMessages \(error.description)")
        }
    }

}
