//
//  Broker.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
typealias BrokerCallback = (String? -> ())?

class Broker: BaseClient {
    
    private var consumers = [String:Consumer]()
    private var producers = [String:Producer]()
    
    var pathToBinary: String
    
    var kafkaServerStart: String {
        return "/\(pathToBinary)/bin/kafka-server-start.sh"
    }
    
    var kafkaConfigDir: String {
        return "/\(pathToBinary)/config"
    }

    required init(_ model: Server) {
        pathToBinary = model.path_to_bin.trim("/") ?? ""
        super.init(model)
    }

    func getKafkaPID(callback: (Int? -> ())? = nil) {
        getProcessId("kafka.Kafka", callback: callback)
    }
    
    func read() {
    
    }
    
    func write() {
        
    }
    
    func log(path: String, callback: BrokerCallback = nil) -> Subprocess? {
        do {
            return try ssh.poll(["tail", "-f", path]) { output in
                self.poll(output)
            }
        } catch {
            print("Polling failed for \(path)")
        }
        
        return nil
    }
    
    func consume(consumer: Consumer, callback: BrokerCallback = nil) {
        delegate?.poll(
            "\n--- Initializing Consumer \(username)@\(address) ---\n"
        )

        do {
            try ssh.wait(
                consumer.path.split(" ")
            ) { output in
                self.consumers[consumer.process] = consumer
                self.poll(output)
                callback?(output)
            }
        } catch {
            print("Unable to start consumer task.")
        }
    }

    override func start(callback: BrokerCallback = nil) -> Self {
        delegate?.poll(
            "\n--- Restarting Kafka Client \(username)@\(address) ---\n"
        )

        do {
            try ssh.wait([
                kafkaServerStart,
                "-daemon",
                "\(kafkaConfigDir)/server.properties"
            ]) { output in
                self.poll(output)
                callback?(output)
            }
        } catch {
            print("Unable to complete task")
        }
        
        return self
    }
    
    override func stop(callback: (String? -> ())? = nil) -> Self {
        if let processId = pid {
            delegate?.poll(
                "\n--- Stopping Kafka Client \(username)@\(address) ---\n"
            )

            do {
                try ssh.wait([
                    SystemBinaries.kill.rawValue,
                    "-9",
                    "\(processId)"
                ]) { output in
                    self.poll(output)
                    callback?(output)
                }
            } catch {
                print("Unable to complete task")
            }
        }
        return self
    }

    override func refresh(callback: (String? -> ())? = nil) -> Self {
        delegate?.poll(
            "\n--- Refreshing Kafka Client \(username)@\(address) ---\n"
        )

        do {
            try ssh.wait([
                SystemBinaries.rm.rawValue,
                "-rf",
                "/tmp/kafka-logs/*"
            ]) { output in
                self.poll(output)
                callback?(output)
            }
        } catch {
            print("Unable to refresh")
        }
        
        return self
    }
}