//
//  BaseProcess.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/12/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

class BaseProcess: NSObject {

    var pid: Int?

    var path: String
    var process: String
    var logPath: String?
    
    required init(model: CustomProcess) {
        self.path = model.path
        self.logPath = model.log_path
        self.process = model.process
    }

    class func each<T: BaseProcess, E: CustomProcess>(processes: [E], callback: T -> ()) {
        for process in processes {
            callback(T.init(model: process))
        }
    }

}