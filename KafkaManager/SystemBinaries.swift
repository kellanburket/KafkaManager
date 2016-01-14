//
//  SystemBinaries.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

enum SystemBinaries: String {
    case grep = "/bin/grep"
    case head = "/usr/bin/head"
    case ps = "/bin/ps"
    case ssh = "/usr/bin/ssh"
    case which = "/usr/bin/which"
    case rm = "/bin/rm"
    case kill = "/bin/kill"
    case nohup = "/usr/bin/nohup"
    case env = "/bin/env"
    case bash = "/bin/bash"
}