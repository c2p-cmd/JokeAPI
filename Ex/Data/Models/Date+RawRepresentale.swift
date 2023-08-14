//
//  Date+RawRepresentale.swift
//  Ex
//
//  Created by Sharan Thakur on 14/08/23.
//

import Foundation

extension Date: RawRepresentable {
    public init?(rawValue: TimeInterval) {
        let timeIntervalSince1970 = rawValue
        
        if timeIntervalSince1970 <= 0.0 {
            return nil
        }
        
        self.init(timeIntervalSince1970: timeIntervalSince1970)
    }
    
    public var rawValue: TimeInterval {
        self.timeIntervalSince1970
    }
}
