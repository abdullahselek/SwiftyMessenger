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

    private static let groupIdentifier = "group.com.abdullahselek.swiftymessenger"
    private static let directory = "messenger"

    private var messenger: Messenger!
    private var watchConnectivityMessenger: Messenger!
    private var messengerListeningSession: MessengerSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        messenger = Messenger(withApplicationGroupIdentifier: ViewController.groupIdentifier, directory: ViewController.directory)
        messengerListeningSession = MessengerSession.shared
        watchConnectivityMessenger = Messenger(withApplicationGroupIdentifier: ViewController.groupIdentifier,
                                               directory: ViewController.directory,
                                               transitingType: .sessionContext)

        messenger.listenForMessage(withIdentifier: "button") { message in

        }

        watchConnectivityMessenger.listenForMessage(withIdentifier: "button") { message in

        }
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
