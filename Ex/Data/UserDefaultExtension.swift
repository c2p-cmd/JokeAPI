//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

// MARK: - APPSTORAGE to use
let appStorage = UserDefaults(suiteName: "group.kida")!

// MARK: - UserDefaults SpeedTest Extension
extension UserDefaults {
    static let defaultSpeed: Speed = Speed(value: 0.0, units: .Kbps)
    
    static var savedSpeed: Speed {
        guard let speedRawValue = appStorage.string(forKey: "net_speed"),
              let speed = Speed(rawValue: speedRawValue)
        else {
            return UserDefaults.defaultSpeed
        }
        
        return speed
    }
    
    static func saveNewSpeed(_ speed: Speed) {
        appStorage.set(speed.rawValue, forKey: "net_speed")
    }
}

// MARK: - UserDefaults Quote Extension
extension UserDefaults {
    static let defaultQuote = QuoteApiResponse("Much wisdom often goes with fewest words.", by: "Sophocles")
    
    static var savedQuote: QuoteApiResponse {
        (appStorage.object(forKey: "quote") as? QuoteApiResponse) ?? UserDefaults.defaultQuote
    }
    
    static func saveNewQuote(
        _ newQuote: QuoteApiResponse
    ) {
        appStorage.set(newQuote.content, forKey: "quote")
    }
}

// MARK: - UserDefaults Joke Extension
extension UserDefaults {
    static let defaultJoke = "Why do Java Programmers have to wear glasses?\n\nBecause they don't C#."
    
    static var savedJoke: String {
        appStorage.string(forKey: "save_joke") ?? UserDefaults.defaultJoke
    }
    
    static func saveNewJoke(
        _ newJoke: String
    ) {
        appStorage.set(newJoke, forKey: "save_joke")
    }
}
