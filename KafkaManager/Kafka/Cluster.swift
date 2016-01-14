//
//  Cluster.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/11/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

typealias BaseCallback = (() -> ())

class Cluster {

    private var zookeepers = [ZookeeperClient]()
    private var brokers = [Broker]()
    private var consumers = [Int:(Broker, Consumer)]()
    
    private var brokersInitialized = false
    private var zookeepersInitialized = false
    
    private var currentLogSubprocess: Subprocess?

    private var totalConsumers: Int {
        return CustomConsumer.fetchAll().count
    }
    
    init(delegate: SSHDelegate) {
        let servers: [KafkaServer] = KafkaServer.fetchAll()
        var brokersLoaded = 0
        
        Broker.each(servers) { (client: Broker) in
            client.delegate = delegate
            
            client.getKafkaPID { id in
                self.addBroker(client)
                ++brokersLoaded
                if brokersLoaded == servers.count {
                    self.brokersInitialized = true
                }
            }
        }

        let zkServers: [ZookeeperServer] = ZookeeperServer.fetchAll()
        var zookeepersLoaded = 0
        ZookeeperClient.each(zkServers) { (zk: ZookeeperClient) in
            zk.delegate = delegate
            
            zk.getZookeeperPID { id in
                self.addZookeeper(zk)
                ++zookeepersLoaded
                if zookeepersLoaded == zkServers.count {
                    self.zookeepersInitialized = true
                }
            }
        }
    }
    
    func log(address: String, path: String, callback: BaseCallback? = nil) {
        onInit {
            if let subprocess = self.currentLogSubprocess {
                subprocess.terminate()
            }

            for broker in self.brokers {
                if broker.address == address {
                    broker.getProcessId(path) { id in
                        if let pid = id {
                            broker.kill(pid) { output in
                                self.currentLogSubprocess = broker.log(path)
                            }
                        } else {
                            self.currentLogSubprocess = broker.log(path)
                        }
                    }
                }
            }
        }
    }

    func addBroker(broker: Broker) {
        brokers.append(broker)
    }

    func addZookeeper(zookeeper: ZookeeperClient) {
        zookeepers.append(zookeeper)
    }
    
    func getBrokerAtAddress(address: String, callback: Broker -> ()) {
        onInit {
            print("Count of Brokers: \(self.brokers.count)")
            var i = 0
            for broker in self.brokers {
                ++i
                print("\(i). \(broker.address)")
                if broker.address == address {
                    callback(broker)
                    break
                }
            }
        }
    }
    
    func startBrokers(callback: BaseCallback? = nil) {
        var brokersLoaded = 0
            
        onInit {
            for broker in self.brokers {
                broker.start { output in
                    ++brokersLoaded
                    if brokersLoaded == self.brokers.count {
                        callback?()
                    }
                }
            }
        }
    }
    
    func stopConsumers(callback: BaseCallback? = nil) {
        var consumersFound = 0
        if totalConsumers == 0 {
            callback?()
            return
        }

        findConsumerServers { broker, consumer in
            if let pid = consumer.pid {
                broker.kill(pid)
            }

            ++consumersFound
            
            if consumersFound == self.totalConsumers {
                callback?()
            }
        }
    }
    
    func findConsumerServers(block: (Broker, Consumer) -> ()) {
        onInit {
            let models: [CustomConsumer] = CustomConsumer.fetchAll()
            
            for model in models {
                if let kafkaServer = model.kafka_server as? KafkaServer {
                    var idAccessed = false
                    self.getBrokerAtAddress(kafkaServer.ip) { broker in
                        broker.getProcessId(model.process) { id in
                            let consumer = Consumer(model: model)
                            consumer.pid = id
                            block(broker, consumer)
                            idAccessed = true
                        }
                    }
                    
                    while !idAccessed {}
                }
            }
        }
    }

    func startConsumers(callback: BaseCallback? = nil) {
        var consumersFound = 0

        if totalConsumers == 0 {
            callback?()
            return
        }
        
        findConsumerServers { broker, consumer in
            if let pid = consumer.pid {
                self.consumers[pid] = (broker, consumer)
            } else {
                broker.consume(consumer) { output in
                    broker.getProcessId(consumer.process) { pid in
                        if let processId = pid {
                            self.consumers[processId] = (broker, consumer)
                        }
                    }
                }
            }

            ++consumersFound

            if consumersFound == self.totalConsumers {
                callback?()
            }
        }
    }
    
    func restart(callback: BaseCallback? = nil) {
        onInit {
            var consumersKilled = 0
            self.findConsumerServers { broker, consumer in
                if let pid = consumer.pid {
                    broker.kill(pid) { _ in
                        ++consumersKilled
                    }
                } else {
                   ++consumersKilled
                }
            }

            while consumersKilled < self.totalConsumers {}
            
            var refreshes = 0

            for broker in self.brokers {
                broker.restart { _ in
                    ++refreshes
                    if refreshes == self.brokers.count {
                        var launched = 0
                        for zk in self.zookeepers {
                            zk.restart { output in
                                zk.poll(output)
                                ++launched
                                if launched == self.zookeepers.count {
                                    self.startBrokers {
                                        self.startConsumers {
                                            callback?()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func onInit(callback: BaseCallback) {
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_DEFAULT,
                0
            )
        ) {
            while !self.brokersInitialized || !self.zookeepersInitialized {}
            callback()
        }
    }
}