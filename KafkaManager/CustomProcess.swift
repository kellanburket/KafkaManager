//
//  CustomProcess.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/11/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa



class CustomProcess: Model {

    enum Status: String {
        case Active = "Active"
        case Inactive = "Inactive"
        case Unknown = "Unknown"
    }
    
    @NSManaged var path: String
    @NSManaged var log_path: String
    @NSManaged var kafka_server: NSManagedObject
    @NSManaged var process: String

    var status: Status = Status.Unknown
}

class CustomConsumer: CustomProcess {
    override class var entityName: String {
        return "CustomConsumer"
    }
}

class CustomProducer: CustomProcess {

    override class var entityName: String {
        return "CustomProducer"
    }
}
