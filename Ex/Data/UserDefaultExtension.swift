//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

// MARK: - APPSTORAGE to use
let appStorage = UserDefaults(suiteName: "group.kida")!

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
