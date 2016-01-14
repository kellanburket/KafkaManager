//
//  Extensions.swift
//  KafkaManager
//
//  Created by Kellan Cummings on 1/10/16.
//  Copyright © 2016 Kellan Cummings. All rights reserved.
//

import Foundation

extension Array {
    mutating func shift() -> Element? {
        return self.count > 0 ? self.removeAtIndex(0) : nil
    }
}