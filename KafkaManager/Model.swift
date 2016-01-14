//
//  Model.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/11/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class Model: NSManagedObject {
    
    class var entityName: String {
        return ""
    }
    
    class var context: NSManagedObjectContext {
        let delegate =
        NSApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    class func fetchAll<T: Model>() -> [T] {
        let request = NSFetchRequest(entityName: entityName)
        
        do {
            let results = try context.executeFetchRequest(request)
            if let objects = results as? [T] {
                return objects
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    class func create(values: [String: AnyObject]) -> Bool {
        
        let model = NSEntityDescription.insertNewObjectForEntityForName(
            entityName,
            inManagedObjectContext: context
        )

        for (key, value) in values {
            model.setValue(value, forKey: key)
        }
                
        do {
            try model.managedObjectContext?.save()
            return true
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    func delete() throws {
        self.dynamicType.context.deleteObject(self)
        try self.dynamicType.context.save()
    }
    
    func update(var keys: [String], _ value: AnyObject?) throws {
        if keys.count == 2 {
            if let key = keys.shift(),
                managed_object = valueForKey(key)
            {
                setValue(managed_object, forKey: key)
            }
        } else if keys.count == 1 {
            if let key = keys.first {
                setValue(value, forKey: key)
                try self.dynamicType.context.save()
            }
        } else {
            print("Unable to parse argument '\(keys)' for update.")
        }
    }

    func valueForKeys(var keys: [String]) -> AnyObject? {
        if let key = keys.shift(),
            value = valueForKey(key)
        {
            if value is NSManagedObject {
                if let attribute = keys.shift() {
                    return value.valueForKey(attribute)
                }
            } else {
                return value
            }
        }

        return nil
    }
    
}