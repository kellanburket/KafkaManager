//
//  BaseClient.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

typealias PollCallback = (String? -> ())?

class BaseClient: NSObject, SSHDelegate {

    var username: String
    var address: String
    var pid: Int?

    var delegate: SSHDelegate?

    class func each<T: BaseClient, E: Server>(models: [E], callback: T -> ()) {
        for model in models {
            callback(T.init(model))
        }
    }
    
    required init(_ model: Server) {
        self.username = model.username ?? ""
        self.address = model.ip ?? ""
        super.init()
    }

    lazy var ssh: SSH = {
        let ssh = SSH(username: self.username, ip: self.address)
        ssh.delegate = self
        return ssh
    }()
    
    func getProcessId(name: String, callback: (Int? -> ())? = nil) {
        do {
            try ssh.getProcessId(name) { id in
                if id != nil {
                    self.pid = id
                    self.delegate?.poll(
                        "\n--- Retreived pid(\(self.pid!)) for '\(name)'" +
                        " on \(self.username)@\(self.address) ---\n"
                    )
                } else {
                    self.delegate?.poll(
                        "\n--- Unable to retreive pid for '\(name)'" +
                        " on \(self.username)@\(self.address) ---\n"
                    )
                }
                callback?(id)
            }
        } catch {
            print("Unable to complete task")
        }
    }
    
    func stop(callback: PollCallback = nil) -> Self {
        return self
    }

    func start(callback: PollCallback = nil) -> Self {
        return self
    }

    func refresh(callback: PollCallback = nil) -> Self {
        return self
    }
    
    func kill(pid: Int, callback: PollCallback = nil) {
        delegate?.poll(
            "\n--- Attempting to kill process \(pid)" +
            "on \(username)@\(address) ---\n"
        )

        do {
            try ssh.wait([
                SystemBinaries.kill.rawValue,
                "-9",
                String(pid)
            ]) { output in
                self.poll(output)
                callback?(output)
            }
        } catch {
            print("Unable to kill process \(pid)")
        }
    }

    func restart(callback: PollCallback = nil) {
        if pid != nil {
            stop { output in
                self.poll(output)
                self.refresh { output in
                    self.poll(output)
                    self.start(callback)
                }
            }
        } else {
            refresh { output in
                self.poll(output)
                self.start(callback)
            }
        }
    }
    
    func poll(output: String?) {
        if var message = output, let sshDelegate = delegate {
            message = message.trim()
            if message.characters.count > 0 {
                sshDelegate.poll("[\(self.username)@\(self.address)]:\n")
                sshDelegate.poll("\t" + message.gsub("\n", "\t\n"))
                sshDelegate.poll("\n")
            }
        }
    }
}