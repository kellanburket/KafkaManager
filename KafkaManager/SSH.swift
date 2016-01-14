//
//  ssh.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/8/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

protocol SSHDelegate {
    func poll(output: String?);
}

class SSH {
    
    private let launchPath = SystemBinaries.ssh.rawValue

    private var username: String
    private var ip: String
    
    private var loginString: String {
        return "\(username)@\(ip)"
    }

    var delegate: SSHDelegate?

    init(username: String, ip: String) {
        self.username = username
        self.ip = ip
    }
    
    func poll(args: [String], callback: (String -> ())? = nil) throws -> Subprocess {
        let subprocess = Subprocess([launchPath, loginString] + args)
        return try poll(subprocess, callback: callback)
    }

    func poll(subprocess: Subprocess, callback: (String -> ())? = nil) throws -> Subprocess {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            subprocess.swim().poll { output in
                if let callback_function = callback {
                    callback_function(output)
                } else {
                    self.delegate?.poll(output == "" ? "\n" : output)
                }
            }
        }

        return subprocess
    }

    func wait(subprocess: Subprocess, callback: (String -> ())? = nil) throws {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            subprocess.swim().wait { output in
                if let callback_function = callback {
                    callback_function(output)
                } else {
                    self.delegate?.poll(output == "" ? "\n" : output)
                }
            }
        }
    }

    func wait(args: [String], callback: (String -> ())? = nil) throws {
        let subprocess = Subprocess([launchPath, loginString] + args)
        try wait(subprocess, callback: callback)
    }
    
    func getProcessId(name: String, callback: (Int? -> ())? = nil) throws {
        try wait(
            Subprocess([
               launchPath, loginString,
                SystemBinaries.ps.rawValue, "ax"
            ]).pipe([
                launchPath, loginString,
                SystemBinaries.grep.rawValue, "-e", "'\(name)'"
            ]).pipe([
                launchPath, loginString,
                SystemBinaries.grep.rawValue, "-v", "grep"
            ]).pipe([
                launchPath, loginString,
                SystemBinaries.grep.rawValue, "-oP", "\"(?<=^|\\s)(\\d+)(?=\\s)\""
            ]).pipe([
                launchPath, loginString,
                SystemBinaries.head.rawValue, "-1"
            ])
        ) { output in
            if let callback_function = callback {
                if output != "" {
                    if let id = Int(output.trim()) {
                        callback_function(id)
                    } else {
                        callback_function(nil)
                    }
                } else {
                    callback_function(nil)
                }
            }
        }
    }
}