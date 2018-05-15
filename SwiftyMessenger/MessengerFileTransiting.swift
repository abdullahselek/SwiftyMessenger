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
    func writeMessage(message: [String: Any]?, identifier: String) -> Bool

    /**
      For reading and returning the contents of a given message. It should
      understand the structure of messages saved by the implementation of the above writeMessage
      method and be able to read those messages and return their contents.

      - parameter identifier: The identifier for the message
      - return: Optional message dictionary
     */
    func messageForIdentifier(identifier: String?) -> [String: Any]?

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
    func notifyListenerForMessage(withIdentifier identifier: String?, message: [String: Any]?)

}
