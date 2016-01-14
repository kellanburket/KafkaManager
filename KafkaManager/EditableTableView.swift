//
//  EditableTableView.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/9/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa
import CoreData

class EditableTableView: NSTableView {

    var objects: [NSManagedObject] = []
    var keyboardRowInteractionDelegate: KeyboardRowInteractionDelegate?
    
    override func keyDown(theEvent: NSEvent) {
        if let key = theEvent.charactersIgnoringModifiers?.unicodeScalars.first {
            if key.value == UInt32(NSDeleteCharacter) {
                if let delegate = keyboardRowInteractionDelegate {
                    delegate.onDelete(selectedRow)
                }
            } else {
                super.keyDown(theEvent)
            }
        } else {
            super.keyDown(theEvent)
        }
    }

}