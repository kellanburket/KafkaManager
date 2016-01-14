//
//  ServerViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/11/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import CoreData

class ServerViewController: ViewController {
    
    override class var columnIdsToAttributes: [String:[String]] {
        return [
            "usernameColumn": ["username"],
            "ipColumn": ["ip"],
            "pathColumn": ["path_to_bin"]
        ]
    }
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var ipField: NSTextField!
}