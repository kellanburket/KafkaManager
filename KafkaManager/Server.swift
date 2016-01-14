//
//  Server.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/8/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class Server: Model {
    @NSManaged var ip: String
    @NSManaged var path_to_bin: String
    @NSManaged var username: String
}

class KafkaServer: Server {
    override class var entityName: String {
        return "KafkaServer"
    }
    
    @NSManaged var role: String
}

class ZookeeperServer: Server {
    override class var entityName: String {
        return "ZookeeperServer"
    }
}