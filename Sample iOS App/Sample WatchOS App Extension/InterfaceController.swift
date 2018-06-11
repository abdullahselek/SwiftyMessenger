//
//  InterfaceController.swift
//  Sample WatchOS App Extension
//
//  Created by Abdullah Selek on 03.06.18.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyMessenger

class InterfaceController: WKInterfaceController {

    private static let groupIdentifier = "group.com.abdullahselek.swiftymessenger"
    private static let directory = "messenger"

    private var messengerSession: MessengerSession!
    private var messenger: Messenger!

    @IBOutlet weak var selectedCellLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        messengerSession = MessengerSession.shared
        messenger = Messenger(withApplicationGroupIdentifier: InterfaceController.groupIdentifier,
                              directory: InterfaceController.directory,
                              transitingType: .sessionContext)

        if let message = messenger.messageForIdentifier(identifier: "selection") as? [String: Any] {
            let string = message["selectedCell"] as? String
            selectedCellLabel.setText(string)
        }

        messengerSession.listenForMessage(withIdentifier: "selection") { message in
            guard let message = message as? [String: Any] else {
                return
            }
            let string = message["selectedCell"] as? String
            self.selectedCellLabel.setText(string)
        }
        messengerSession.activateSession()
    }

    @IBAction func didObjCTap(sender: WKInterfaceButton) {
        messenger.passMessage(message: ["buttonTitle": "Objective-C"], identifier: "button")
    }

    @IBAction func didSwiftTap(sender: WKInterfaceButton) {
        messenger.passMessage(message: ["buttonTitle": "Swift"], identifier: "button")
    }

    @IBAction func didXcodeTap(sender: WKInterfaceButton) {
        messenger.passMessage(message: ["buttonTitle": "Xcode"], identifier: "button")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
