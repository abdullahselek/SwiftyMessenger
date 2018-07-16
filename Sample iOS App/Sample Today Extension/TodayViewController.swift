//
//  TodayViewController.swift
//  Sample Today Extension
//
//  Created by Abdullah Selek on 16.07.18.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyMessenger

class TodayViewController: UIViewController, NCWidgetProviding {

    private static let groupIdentifier = "group.com.abdullahselek.swiftymessenger"
    private static let directory = "messenger"
    private var messenger: Messenger!

    override func viewDidLoad() {
        super.viewDidLoad()
        messenger = Messenger(withApplicationGroupIdentifier: TodayViewController.groupIdentifier,
                              directory: TodayViewController.directory)
    }

    @IBAction func oneTapped(_ sender: Any) {
        messenger.passMessage(message: ["buttonTitle": "Today-One"], identifier: "button")
    }

    @IBAction func twoTapped(_ sender: Any) {
        messenger.passMessage(message: ["buttonTitle": "Today-Two"], identifier: "button")
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
