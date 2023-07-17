//
//  JokeType.swift
//  Ex
//
//  Created by Sharan Thakur on 17/07/23.
//

enum JokeType: String {
    case single = "single"
    case twopart = "twopart"
    case any = "Any"
    
    var description: String {
        switch self {
        case .single:
            return "Single"
        case .twopart:
            return "Two Part"
        case .any:
            return "Any"
        }
    }
    
    static var allCase: [JokeType] = [
        .any,
        .single,
        .twopart
    ]
}
