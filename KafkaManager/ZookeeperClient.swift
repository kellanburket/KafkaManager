//
//  Zookeeper.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

class ZookeeperClient: BaseClient {

    var pathToBinary: String

    var zkServer: String {
        return "/\(pathToBinary)/zkServer.sh"
    }
    
    required init(_ model: Server) {
        self.pathToBinary = model.path_to_bin.trim("/") ?? ""
        super.init(model)
    }

    func getZookeeperPID(callback: (Int? -> ())? = nil) {
        getProcessId("zookeeper", callback: callback)
    }

    override func start(callback: (String? -> ())? = nil) -> Self {
        do {
            try ssh.wait([zkServer, "start"], callback: callback)
        } catch {
            print("Unable to complete task")
        }

        return self
    }
    
    override func stop(callback: (String? -> ())? = nil) -> Self {

        if let processId = pid {
            delegate?.poll(
                "\n--- Stopping Zookeeper Client \(username)@\(address) ---\n"
            )

            do {
                try ssh.wait([
                    SystemBinaries.kill.rawValue,
                    "-9",
                    "\(processId)"
                ], callback: callback)

            } catch {
                print("Unable to complete task")
            }
        } else {
            do {
                try ssh.wait([zkServer, "stop"], callback: callback)
            } catch {
                print("Unable to complete task")
            }
        }
        
        return self
    }
    
    override func refresh(callback: (String? -> ())? = nil) -> Self {
        delegate?.poll(
            "\n--- Refreshing Zookeeper Client \(username)@\(address) ---\n"
        )

        do {
            try ssh.wait([
                SystemBinaries.rm.rawValue,
                "-rf",
                "/tmp/zookeeper/*"
            ], callback: callback)
        } catch {
            print("Unable to refresh")
        }

        return self
    }
}