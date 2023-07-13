//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

// MARK: - APPSTORAGE to use
let appStorage = UserDefaults(suiteName: "group.com.kidastudios.mygroup")!

// MARK: - UserDefaults Pexels Photo Extension
extension UserDefaults {
    static var defaultPexelsPhotoResponse: MultiPhotoResponse {
        let src = Src(large: "https://images.pexels.com/photos/16575029/pexels-photo-16575029.jpeg?auto=compress&cs=tinysrgb&h=650&w=940")
        return MultiPhotoResponse(photos: [PexelsPhotoResponse(id: 16575029, width: 3794, height: 3794, src: src, alt: "Cute Kittens Looking from Window")])
    }
    
    static var savedPexelsPhotoResponse: MultiPhotoResponse {
        guard let savedPexelsPhoto = appStorage.string(forKey: "pexels_photo"),
              let pexelsPhoto = MultiPhotoResponse(rawValue: savedPexelsPhoto) else {
            return defaultPexelsPhotoResponse
        }
        return pexelsPhoto
    }
    
    func saveNewPexelsPhotoResponse(_ newResponse: MultiPhotoResponse) {
        appStorage.set(newResponse, forKey: "pexels_photo")
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
