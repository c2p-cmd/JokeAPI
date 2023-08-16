//
//  IdentifiableString.swift
//  Ex
//
//  Created by Sharan Thakur on 16/08/23.
//

import Foundation

struct IdentifiableString: Identifiable, Hashable, RawRepresentable {
    let string: String
    var id: String { string }
    
    init(string: String) {
        self.string = string
    }
    
    init(rawValue: String) {
        self.string = rawValue
    }
    
    var rawValue: String {
        self.string
    }
}

