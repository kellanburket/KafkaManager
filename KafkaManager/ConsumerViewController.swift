//
//  ConsumerViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/9/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class ConsumerViewController: ViewController {
    override class var model: Model.Type {
        return CustomConsumer.self
    }

    var kafkaServers: [KafkaServer] {
        return KafkaServer.fetchAll()
    }
    
    private var autoscroll = true

    @IBOutlet var consoleTextView: NSTextView?
    @IBOutlet weak var kafkaServersList: NSPopUpButton!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var logPathField: NSTextField!
    @IBOutlet weak var processField: NSTextField!
    
    @IBOutlet weak var consoleScroller: NSScrollView!
    
    override class var columnIdsToAttributes: [String:[String]] {
        return [
            "pathColumn": ["path"],
            "kafkaServerColumn": ["kafka_server", "role"],
            "logPathColumn": ["log_path"],
            "processColumn": ["process"]
        ]
    }
    
    @IBAction func onAddNodeClick(sender: NSButton) {
        if let index = kafkaServersList?.indexOfSelectedItem,
            path = pathField?.stringValue,
            logPath = logPathField?.stringValue,
            process = processField?.stringValue
        {
            
            if CustomConsumer.create([
                "path": path,
                "log_path": logPath,
                "kafka_server": kafkaServers[index],
                "process": process
            ]) {
                print("Save was successful")
                nodesTable?.reloadData()
            } else {
                print("Save was unsuccessful")
            }
        }

        logPathField?.stringValue = ""
        pathField?.stringValue = ""
        processField?.stringValue = ""
    }
    
    override func awakeFromNib() {
        refreshPopUpList()
    }
    
    private func refreshPopUpList() {
        kafkaServersList.removeAllItems()
        
        for kafkaServer in kafkaServers {
            kafkaServersList.addItemWithTitle(kafkaServer.role)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consoleTextView?.string! = ""
        consoleScroller?.contentView.postsBoundsChangedNotifications = true
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "consoleDidScroll:",
            name: NSViewBoundsDidChangeNotification,
            object: nil
        )
    }
    
    func consoleDidScroll(notification: NSNotification) {
        if let visibleRect = consoleScroller?.contentView.documentVisibleRect,
            maxRect = consoleScroller?.contentView.documentRect
        {
            let currentOffset = visibleRect.origin.y
            let maxOffset = maxRect.size.height - visibleRect.size.height
            
            if currentOffset >= maxOffset {
                autoscroll = true
            } else {
                autoscroll = false
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        refreshPopUpList()
    }

    override func poll(output: String?) {
        if let msg = output {
            let attributedString = msg.attribute([
                "(\\[.*?@.*?\\])": [self.consoleTextColor],
                "(-- .*? --)": [self.consoleInfoColor],
                "(?sm:\\[33m(.*?)\\[0m)": [self.consoleInfoColor],
                "(?sm:\\[34m(.*?)\\[0m)": [self.consoleWarnColor],
                "(?sm:\\[31m(.*?)\\[0m)": [self.consoleErrorColor]
            ])
            
            dispatch_async(dispatch_get_main_queue()) {
                self.consoleTextView?.textStorage?.appendAttributedString(attributedString)

                if self.autoscroll {
                    self.consoleTextView?.scrollToEndOfDocument(self)
                }
            }
        }
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let tableView = notification.object as? NSTableView,
            customConsumer = models[tableView.selectedRow] as? CustomConsumer
        {
            if let kafkaServer = customConsumer.kafka_server as? KafkaServer {
                cluster.log(kafkaServer.ip, path: customConsumer.log_path)
            }
        }
    }
}