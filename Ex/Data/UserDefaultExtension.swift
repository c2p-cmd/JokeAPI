//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

// MARK: - APPSTORAGE to use
let appStorage = UserDefaults(suiteName: "group.com.kidastudios.mygroup")!

// MARK: - UserDefaults RedditMemeResponse Extension
extension UserDefaults {
    static var defaultRedditAnimalResponse: RedditMemeResponse {
        return RedditMemeResponse(title: "This Cute Rottweiler Pup 🐶", url: "https://i.redd.it/vvbzgl9scacb1.jpg", nsfw: false)
    }
    
    static var savedRedditAnimalResponse: RedditMemeResponse {
        guard let saved = appStorage.string(forKey: "reddit_meme"),
              let response = RedditMemeResponse(rawValue: saved) else {
            return defaultRedditAnimalResponse
        }
        return response
    }
    
    static func saveNewRedditAnimalResponse(_ newResponse: RedditMemeResponse) {
        appStorage.set(newResponse.rawValue, forKey: "reddit_meme")
    }
}

// MARK: - UserDefaults NASA Apod Extension
extension UserDefaults {
    static var savedApod: ApodResponse? {
        guard let apodRawValue = appStorage.string(forKey: "nasa_apod"),
              let apod = ApodResponse(rawValue: apodRawValue) else {
            return nil
        }
        return apod
    }
    
    static func saveNewNASAApod(_ apodResponse: ApodResponse) {
        appStorage.set(apodResponse.rawValue, forKey: "nasa_apod")
    }
}

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
        guard let quoteRawValue = appStorage.string(forKey: "quote"),
              let quote = QuoteApiResponse(rawValue: quoteRawValue)
        else {
            return UserDefaults.defaultQuote
        }
        
        return quote
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
