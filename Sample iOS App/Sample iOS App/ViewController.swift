//
//  ViewController.swift
//  Sample iOS App
//
//  Created by Abdullah Selek on 03.06.18.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import UIKit
import SwiftyMessenger

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedButtonLabel: UILabel!

    private static let groupIdentifier = "group.com.abdullahselek.swiftymessenger"
    private static let directory = "messenger"

    private var messenger: Messenger!
    private var watchConnectivityMessenger: Messenger!
    private var messengerListeningSession: MessengerSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()

        messenger = Messenger(withApplicationGroupIdentifier: ViewController.groupIdentifier, directory: ViewController.directory)
        messengerListeningSession = MessengerSession.shared
        watchConnectivityMessenger = Messenger(withApplicationGroupIdentifier: ViewController.groupIdentifier,
                                               directory: ViewController.directory,
                                               transitingType: .sessionContext)

        messenger.listenForMessage(withIdentifier: "button") { message in
            guard let message = message as? [String: Any] else {
                return
            }
            let buttonTitle = message["buttonTitle"] as? String
            self.selectedButtonLabel.text = buttonTitle
        }

        watchConnectivityMessenger.listenForMessage(withIdentifier: "button") { message in
            guard let message = message as? [String: Any] else {
                return
            }
            let buttonTitle = message["buttonTitle"] as? String
            self.selectedButtonLabel.text = buttonTitle
        }
        messengerListeningSession.activateSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let message = messenger.messageForIdentifier(identifier: "button") as? [String: Any] {
            let buttonTitle = message["buttonTitle"] as? String
            self.selectedButtonLabel.text = buttonTitle
        }
    
        if let message = watchConnectivityMessenger.messageForIdentifier(identifier: "button") as? [String: Any] {
            let buttonTitle = message["buttonTitle"] as? String
            self.selectedButtonLabel.text = buttonTitle
        }
    }

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellIdentifier") as! TextTableViewCell
        tableViewCell.titleLabel?.text = String(format: "%d", indexPath.row)
        return tableViewCell
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableViewCell = tableView.cellForRow(at: indexPath) as? TextTableViewCell
        let title = tableViewCell?.titleLabel.text

        // Pass a message for the selection identifier.
        messenger.passMessage(message: ["selectedCell": title], identifier: "selection")
        watchConnectivityMessenger.passMessage(message: ["selectedCell": title], identifier: "selection")
    }

}

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

}
