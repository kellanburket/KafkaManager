//
//  ZookeeperViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/9/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class ZookeeperViewController: ServerViewController {
    override class var model: Model.Type {
        return ZookeeperServer.self
    }
    
    @IBAction func onAddNodeClick(sender: NSButton) {
        if let username = usernameField?.stringValue,
            ip = ipField?.stringValue,
            pathToBin = pathField?.stringValue
        {
            if ZookeeperServer.create([
                "username": username,
                "ip": ip,
                "path_to_bin": pathToBin
            ]) {
                nodesTable?.reloadData()
            } else {
                print("Save was unsuccessful")
            }
        }
        usernameField?.stringValue = ""
        ipField?.stringValue = ""
        pathField?.stringValue = ""
    }
}