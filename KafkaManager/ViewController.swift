//
//  ViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/8/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import CoreData

protocol KeyboardRowInteractionDelegate {
    func onDelete(row: Int);
}

class ViewController:
    ClusterViewController,
    NSTextFieldDelegate,
    NSTableViewDelegate,
    NSTableViewDataSource,
    KeyboardRowInteractionDelegate
{

    class var model: Model.Type {
        return Model.self
    }
    
    class var columnIdsToAttributes: [String:[String]] {
        return [String:[String]]()
    }

    var models: [Model] {
        return self.dynamicType.model.fetchAll()
    }
    
    @IBOutlet weak var nodesTable: EditableTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        nodesTable.setDelegate(self)
        nodesTable.setDataSource(self)
        nodesTable.keyboardRowInteractionDelegate = self
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return models.count
    }
    
    func tableView(
        tableView: NSTableView,
        objectValueForTableColumn tableColumn: NSTableColumn?,
        row: Int
    ) -> AnyObject? {
        if let columnId = tableColumn?.identifier,
            attributes = self.dynamicType.columnIdsToAttributes[columnId]
        {
            return models[row].valueForKeys(attributes)
        }
        
        return nil
    }

    func tableView(
        tableView: NSTableView,
        setObjectValue object: AnyObject?,
        forTableColumn tableColumn: NSTableColumn?,
        row: Int
    ) {
        if let columnId = tableColumn?.identifier,
            attributes = self.dynamicType.columnIdsToAttributes[columnId]
        {
            do {
                try models[row].update(attributes, object)
            } catch {
                print("Was unable to update: \(attributes) => \(object)")
            }
        }
    }

    func tableView(
        tableView: NSTableView,
        shouldEditTableColumn tableColumn: NSTableColumn?,
        row: Int
    ) -> Bool {
        return true
    }

    func onDelete(row: Int) {
        do {
            try models[row].delete()
            nodesTable?.reloadData()
        } catch {
            print("Unable to delete object")
        }
    }
}