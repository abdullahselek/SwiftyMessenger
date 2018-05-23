//
//  MessengerSessionMessageTransiting.swift
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
  Provides support for the WatchConnectivity framework's real time message passing ability.
 */
class MessengerSessionMessageTransiting: MessengerFileTransiting {

    private var session: WCSession!

    override init(withApplicationGroupIdentifier identifier: String, directory: String?) {
        super.init(withApplicationGroupIdentifier: identifier, directory: directory)
        session = WCSession.default
    }

    override func messagePassingDirectoryPath() -> String? {
        return nil
    }

    override func writeMessage(message: Any?, identifier: String) -> Bool {
        if identifier.isEmpty {
            return false
        }
        guard let message = message else {
            return false
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: message)
        if session.isReachable {
            session.sendMessage([identifier: data], replyHandler: nil) { error in
                let nsError = error as NSError
                print("SwiftyMessenger: Error on writeMessage \(nsError.description)")
            }
        }
        return true
    }

}
