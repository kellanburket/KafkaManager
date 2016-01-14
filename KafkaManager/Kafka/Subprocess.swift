//
//  Subprocess.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

protocol SubprocessDelegate {
    func poll(output: String)
}

class Subprocess: NSObject {
    var delegate: SubprocessDelegate?

    var environment: [String:String]? {
        set(args) {
            task.environment = args
        }
        get {
            return task.environment
        }
    }
    
    private var nextSubprocess: Subprocess?
    private var previousSubprocess: Subprocess?

    private var callback: (String -> ())?
    
    private var task: NSTask
    private var output = NSPipe()
    private var error = NSPipe()
    
    private var _terminated = false
    private var _launched = false

    var launched: Bool {
        return _launched
    }
    
    var terminated: Bool {
        return _terminated
    }
    
    var next: Subprocess? {
        return nextSubprocess
    }
    
    required init(
        var _ args: [String],
        input: NSPipe? = nil
    ) {
        task = NSTask()
        task.launchPath = args.shift()
        task.arguments = args
        task.standardOutput = output
        task.standardError = error
        
        if let inputPipe = input {
            task.standardInput = inputPipe
        }
    }
    
    func pipe(args: [String]) -> Subprocess {
        self.nextSubprocess = Subprocess(args, input: self.output)
        self.nextSubprocess?.previousSubprocess = self
        return self.nextSubprocess!
    }
    
    func launch() {
        task.launch()
        _launched = true

        if let subprocess = nextSubprocess {
            subprocess.launch()
        }
    }
    
    func terminate() {
        if let subprocess = nextSubprocess {
            subprocess.terminate()
        }

        task.terminate()
        _terminated = true
    }
    
    func taskDidTerminate(notification: NSNotification) {
        callback?("Task Has Terminated")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        _terminated = true
    }
    
    func taskDidReturnStdOut(notification: NSNotification) {
        if let fileHandle = notification.object as? NSFileHandle {
            if let output = String(
                data: fileHandle.availableData,
                encoding: NSUTF8StringEncoding
            ) {
                callback?(output)
            } else {
                print("Could not decode data")
            }
            
            fileHandle.waitForDataInBackgroundAndNotify()
        }
    }

    func taskDidReturnStdErr(notification: NSNotification) {
        if let fileHandle = notification.object as? NSFileHandle {
            if let output = String(
                data: fileHandle.availableData,
                encoding: NSUTF8StringEncoding
                ) {
                    callback?(output)
            } else {
                print("Could not decode data")
            }
            
            fileHandle.waitForDataInBackgroundAndNotify()
        }
    }

    func wait(callback: (String -> ())) {
        let final_subprocess = sink()
        let fileHandle = final_subprocess.output.fileHandleForReading
        
        launch()

        if let output = String(
            data: fileHandle.readDataToEndOfFile(),
            encoding: NSUTF8StringEncoding
        ) {
            callback(output)
        } else {
            print("Could not decode data")
        }
    }
    
    func poll(callback: (String -> ())) {
        self.callback = callback
        let final_subprocess = sink()
        let fileHandle = final_subprocess.output.fileHandleForReading
        let errorFileHandle = final_subprocess.error.fileHandleForReading

        launch()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "taskDidTerminate:",
            name: NSTaskDidTerminateNotification,
            object: final_subprocess
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "taskDidReturnStdOut:",
            name: NSFileHandleDataAvailableNotification,
            object: fileHandle
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "taskDidReturnStdErr:",
            name: NSFileHandleDataAvailableNotification,
            object: errorFileHandle
        )

        fileHandle.waitForDataInBackgroundAndNotify()
        errorFileHandle.waitForDataInBackgroundAndNotify()

        while !terminated {
            if !NSRunLoop.currentRunLoop().runMode(
                NSDefaultRunLoopMode,
                beforeDate: NSDate.distantFuture()
            ) {
                break;
            }
        }
    }
    
    func sink() -> Subprocess {
        if let subprocess = nextSubprocess {
            return subprocess.sink()
        } else {
            return self
        }
    }
    
    func swim() -> Subprocess {
        if let subprocess = previousSubprocess {
            return subprocess.swim()
        } else {
            return self
        }
    }
}
