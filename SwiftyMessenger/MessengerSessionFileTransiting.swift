//
//  MessengerSessionFileTransiting.swift
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
  Provides support for the WatchConnectivity framework's file transfer ability. This class
  will behave very similar to the MessengerFileTransiting implementation, meaning it will archive
  messages to disk as files and send them via the WatchConnectivity framework's -transferFile API.
 */
open class MessengerSessionFileTransiting: MessengerFileTransiting {

    private var session: WCSession!

    override init(withApplicationGroupIdentifier identifier: String?, directory: String?) {
        super.init(withApplicationGroupIdentifier: identifier, directory: directory)
        session = WCSession.default
    }

    override open func writeMessage(message: Any?, identifier: String) -> Bool {
        if identifier.isEmpty {
            return false
        }
        if !WCSession.isSupported() {
            return false
        }
        guard let message = message else {
            return false
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: message)
        var tempDir = messagePassingDirectoryPath() ?? ""
        if tempDir.isEmpty {
            tempDir = NSTemporaryDirectory()
        }
        guard let tempURL = NSURL(fileURLWithPath: tempDir).appendingPathComponent(identifier) else {
            return false
        }
        do {
            try data.write(to: tempURL)
            session.transferFile(tempURL, metadata: ["identifier": identifier])
        } catch let error as NSError {
            NSLog("SwiftyMessenger: Error on writeMessage \(error.description)")
        }
        return false
    }

}
