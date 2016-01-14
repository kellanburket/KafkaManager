//
//  KafkaViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/9/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class KafkaViewController: ServerViewController {
    override class var model: Model.Type {
        return KafkaServer.self
    }
    
    override class var columnIdsToAttributes: [String:[String]] {
        return [
            "usernameColumn": ["username"],
            "ipColumn": ["ip"],
            "roleColumn": ["role"],
            "pathColumn": ["path_to_bin"]
        ]
    }

    @IBOutlet weak var roleField: NSTextField!

    @IBAction func onAddNodeClick(sender: NSButton) {
        if let username = usernameField?.stringValue,
            ip = ipField?.stringValue,
            role = roleField?.stringValue,
            pathToBin = pathField?.stringValue
        {
            if KafkaServer.create([
                "username": username,
                "ip": ip,
                "role": role,
                "path_to_bin": pathToBin
            ]) {
                nodesTable?.reloadData()
            } else {
                print("Save was unsuccessful")
            }
        }
        usernameField?.stringValue = ""
        ipField?.stringValue = ""
        roleField?.stringValue = ""
        pathField?.stringValue = ""
    }
}