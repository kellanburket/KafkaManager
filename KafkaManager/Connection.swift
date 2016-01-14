//
//  Connection.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

enum ConnectionError: ErrorType {
    case InvalidIpAddress
}


class Connection: NSObject {

    private var host: String
    
    init(host: String) throws {
        self.host = host
        super.init()
        
        var data = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(4))
        
        for bytestring in host.split(".") {
            guard var byte = UInt8(bytestring) else {
                throw ConnectionError.InvalidIpAddress
            }
            
            withUnsafePointer(&byte) { (pointer: UnsafePointer<UInt8>) in
                CFDataAppendBytes(data, pointer, CFIndex(1))
            }
        }
        
        var outputStreamBuffer = UInt8()
        try var outputStreamPointer = withUnsafePointer(&outputStreamBuffer) {(
            pointer: UnsafePointer<UInt8>
        ) -> UnsafeMutablePointer<Unmanaged<CFReadStream>?> in
            guard var outputStream = CFReadStreamCreateWithBytesNoCopy(
                kCFAllocatorDefault,
                pointer,
                CFIndex(2e+8),
                kCFAllocatorDefault
            ) else {
                throw ConnectionError.InvalidIpAddress
            }

            return withUnsafeMutablePointer(&outputStream) { (
                mutablePointer: UnsafeMutablePointer<CFReadStream>
            ) -> UnsafeMutablePointer<CFReadStream> in
                return mutablePointer
            }
        }
        
        
        var inputStream = CFWriteStreamCreateWithAllocatedBuffers(
            kCFAllocatorDefault, kCFAllocatorDefault
        )

        if let cfHost = CFHostCreateWithAddress(
            kCFAllocatorDefault,
            data
        ).takeRetainedValue() as? CFHost {
            var cfStream = CFStreamCreatePairWithSocketToCFHost(
                kCFAllocatorDefault,
                cfHost,
                sint32(9092),
                outputStreamPointer,
                inputStreamPointer
            )
        }
        
        

        
        //CFSocket
        
        //NSOutputStream()
    }
}