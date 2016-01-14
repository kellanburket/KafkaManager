//
//  HomeViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/8/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import CoreData

class HomeViewController: ClusterViewController {
    
    @IBOutlet var consoleTextView: NSTextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        consoleTextView?.string! = ""
    }

    @IBAction func killConsumers(sender: NSButton) {
        sender.enabled = false
        cluster.stopConsumers {
            dispatch_async(dispatch_get_main_queue()) {
                sender.enabled = true
            }
        }
    }
    
    @IBAction func restartCluster(sender: NSButton) {
        sender.enabled = false
        cluster.restart {
            dispatch_async(dispatch_get_main_queue()) {
                sender.enabled = true
            }
        }
    }
    
    @IBAction func startConsumers(sender: NSButton) {
        sender.enabled = false
        cluster.startConsumers {
            dispatch_async(dispatch_get_main_queue()) {
                sender.enabled = true
            }
        }
    }

    override func poll(output: String?) {
        if let msg = output {
            dispatch_async(dispatch_get_main_queue()) {
                self.consoleTextView?.string! += msg
                
                if let visibleRange = self.consoleTextView?.string?.toRange() {
                    self.consoleTextView?.setTextColor(
                        self.consoleTextColor,
                        range: visibleRange
                    )
                    
                    self.consoleTextView?.scrollToEndOfDocument(self)
                }
            }
        }
    }
}