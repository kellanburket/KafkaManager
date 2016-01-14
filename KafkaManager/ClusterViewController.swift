//
//  ClusterViewController.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/12/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation
import Cocoa

class ClusterViewController: NSViewController, SSHDelegate {
    
    lazy var cluster: Cluster = {
        return Cluster(delegate: self)
    }()
    
    var consoleTextColor: NSColor {
        return NSColor(
            red: CGFloat(255.0/255.0),
            green: CGFloat(255.0/255.0),
            blue: CGFloat(155.0/255.0),
            alpha: CGFloat(255.0/255.0)
        )
    }

    var consoleInfoColor: NSColor {
        return NSColor(
            red: CGFloat(243.0/255.0),
            green: CGFloat(212.0/255.0),
            blue: CGFloat(51.0/255.0),
            alpha: CGFloat(255.0/255.0)
        )
    }

    var consoleWarnColor: NSColor {
        return NSColor(
            red: CGFloat(255.0/255.0),
            green: CGFloat(102.0/255.0),
            blue: CGFloat(0.0/255.0),
            alpha: CGFloat(255.0/255.0)
        )
    }

    var consoleErrorColor: NSColor {
        return NSColor(
            red: CGFloat(255.0/255.0),
            green: CGFloat(0.0/255.0),
            blue: CGFloat(0.0/255.0),
            alpha: CGFloat(255.0/255.0)
        )
    }

    func poll(output: String?) {
        //Not Implemented
    }
}