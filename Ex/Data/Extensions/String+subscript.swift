//
//  String+subscript.swift
//  Ex
//
//  Created by Sharan Thakur on 28/09/23.
//

import Foundation

extension String {
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
}
