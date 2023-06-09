//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

extension UserDefaults {
    static let defaultJoke = "Why do Java Programmers have to wear glasses?\n\nBecause they don't C#."
    
    static var savedJoke: String {
        UserDefaults.standard.string(forKey: "save_joke") ?? UserDefaults.defaultJoke
    }
    
    static func saveNewJoke(
        _ newJoke: String
    ) {
        UserDefaults.standard.set(newJoke, forKey: "save_joke")
    }
}
