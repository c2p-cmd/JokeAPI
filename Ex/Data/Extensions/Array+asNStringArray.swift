//
//  Array+asNStringArray.swift
//  Ex
//
//  Created by Sharan Thakur on 16/08/23.
//

import Foundation

extension Array<String> {
    func asNSSTring() -> [NSString] {
        return self.map { NSString(string: $0) }
    }
}
