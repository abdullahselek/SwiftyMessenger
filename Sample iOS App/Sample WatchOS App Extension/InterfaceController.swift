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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
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
