//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

// MARK: - APPSTORAGE to use
let appStorage = UserDefaults(suiteName: "group.com.kidastudios.mygroup")!

extension UserDefaults {
    enum Keys: String, CaseIterable {
        case mcuFilm = "next_mcu_film"
        case bhagvadGita = "bhagvad_gita_response"
        case tvshowquotes = "tv_show_quotes"
    }
}

// MARK: - MCU Films
extension UserDefaults {
    private static let mcuFilmRawValue = """
{
    "days_until": -4499,
    "following_production": {
      "days_until": -4407,
      "overview": "During World War II, Steve Rogers is a sickly man from Brooklyn who's transformed into super-soldier Captain America to aid in the war effort. Rogers must stop the Red Skull – Adolf Hitler's ruthless head of weaponry, and the leader of an organization that intends to use a mysterious device of untold powers for world domination.",
      "poster_url": "https://image.tmdb.org/t/p/w500/vSNxAJTlD0r02V9sPYpOjqDZXUK.jpg",
      "release_date": "2011-07-22",
      "title": "Captain America: The First Avenger",
      "type": "Movie"
    },
    "overview": "Against his father Odin's will, The Mighty Thor - a powerful but arrogant warrior god - recklessly reignites an ancient war. Thor is cast down to Earth and forced to live among humans as punishment. Once here, Thor learns what it takes to be a true hero when the most dangerous villain of his world sends the darkest forces of Asgard to invade Earth.",
    "poster_url": "https://image.tmdb.org/t/p/w500/prSfAi1xGrhLQNxVSUFh61xQ4Qy.jpg",
    "release_date": "2011-04-21",
    "title": "Thor",
    "type": "Movie"
  }
"""
    
    static let defaultNextMCUFilmResponse = NextMcuFilm(rawValue: mcuFilmRawValue)!
    
    static var savedNextMCUFilmResponse: NextMcuFilm {
        guard let responseRawValue = appStorage.string(forKey: "next_mcu_film"),
              let response = NextMcuFilm(rawValue: responseRawValue)
        else {
            return ListofNextMCUFilms.getDummyData().randomElement()!
        }
        
        return response
    }
    
    static func saveNewNextMCUFilmResponse(
        _ newFilm: NextMcuFilm
    ) {
        appStorage.setValue(newFilm.rawValue, forKey: "next_mcu_film")
    }
}

// MARK: - BhagvadGita Response
extension UserDefaults {
    static let defaultBhagvadGitaResponse = BhagvatGitaResponse(
        chapterNo: 1,
        shlokNo: 1,
        shlok: "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||१-१||",
        englishTranslation: "1.1 The King Dhritarashtra asked: \"O Sanjaya! What happened on the sacred battlefield of Kurukshetra, when my people gathered against the Pandavas?\"",
        hindiTranslation: "।।1.1।।धृतराष्ट्र ने कहा -- हे संजय ! धर्मभूमि कुरुक्षेत्र में एकत्र हुए युद्ध के इच्छुक (युयुत्सव:) मेरे और पाण्डु के पुत्रों ने क्या किया?",
        englishAuthor: "Shri Purohit Swami",
        hindiAuthor: "Swami Tejomayananda"
    )
    
    static var savedBhagvatGitaResponses: [BhagvatGitaResponse] {
        let shloaksFromFile = BhagvatGitaResponse.getShlokas()
        
        guard let responseRawValue = appStorage.string(forKey: "bhagvad_gita_response")
        else {
            return shloaksFromFile
        }
        
        let responses = [BhagvatGitaResponse].init(rawValue: responseRawValue)
        
        if responses.isEmpty {
            return shloaksFromFile
        }
        
        return responses
    }
}

// MARK: - TV Show Quote
extension UserDefaults {
    static var savedTVShowQuotes: TVShowQuoteResponses {
        let responses = TVShowQuoteResponses(rawValue: appStorage.string(forKey: "tv_show_quotes") ?? "[]")
        
        if responses.isEmpty {
            return .getSavedQuotes()
        }
        return responses
    }
    
    static func saveNewTVShowQuotes(_ newResponse: TVShowQuoteResponses) {
        var savedResponses = savedTVShowQuotes
        savedResponses.append(contentsOf: newResponse)
        appStorage.set(savedResponses.rawValue, forKey: "tv_show_quotes")
    }
}

// MARK: - UserDefaults Date
extension UserDefaults {
    static var defaultFunFact: String {
        "The word 'date' comes from the Greek word daktylos, meaning finger, because a date looks like the tip of a finger."
    }
    
    static var savedFunFact: String {
        appStorage.string(forKey: "date_fun_fact") ?? defaultFunFact
    }
    
    static func saveNewFunFact(_ line: String) {
        appStorage.setValue(line, forKey: "date_fun_fact")
    }
}

// MARK: - UserDefaults FlirtyLines
extension UserDefaults {
    static var defaultFlirtyLine: String {
        "Are you a camera? Because every time I see you I smile"
    }
    
    static var savedFlirtyLine: String {
        appStorage.string(forKey: "flirty_line") ?? defaultFlirtyLine
    }
    
    static func saveNewFlirtyLine(_ line: String) {
        appStorage.setValue(line, forKey: "flirty_line")
    }
}

// MARK: - UserDefaults RedditMemeResponse Extension
extension UserDefaults {
    static var defaultRedditMemeResponse: RedditMemeResponse {
        return RedditMemeResponse(
            title: "Hoping for an Extraordinary Future for My Newborn",
            url: "https://i.redd.it/5vk4ob6hnrcb1.jpg",
            nsfw: false
        )
    }
    
    static var savedRedditMemeResponse: RedditMemeResponse {
        guard let saved = appStorage.string(forKey: "reddit_memeZ"),
              let response = RedditMemeResponse(rawValue: saved) else {
            return defaultRedditMemeResponse
        }
        return response
    }
    
    static func saveNewRedditMemeResponse(_ newResponse: RedditMemeResponse) {
        appStorage.set(newResponse.rawValue, forKey: "reddit_memeZ")
    }
    
    static var defaultRedditAnimalResponse: RedditMemeResponse {
        return RedditMemeResponse(
            title: "This Cute Rottweiler Pup 🐶",
            url: "https://i.redd.it/vvbzgl9scacb1.jpg",
            nsfw: false
        )
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
    static var defaultApodResponse: ApodResponse {
        ApodResponse(date: "2021-09-08", explanation: "What surrounds the Andromeda galaxy?  Out in space, Andromeda (M31) is closely surrounded by several small satellite galaxies, and further out it is part of the Local Group of Galaxies -- of which our Milky Way galaxy is also a member. On the sky, however, gas clouds local to our Milky Way appear to surround M31 -- not unlike how water clouds in Earth's atmosphere may appear to encompass our Moon.  The gas clouds toward Andromeda, however, are usually too faint to see.  Enter the featured 45-degree long image -- one of the deeper images yet taken of the broader Andromeda region. This image, sensitive to light specifically emitted by hydrogen gas, shows these faint and unfamiliar clouds in tremendous detail. But the image captures more.  At the image top is the Triangulum galaxy (M33), the third largest galaxy in the Local Group and the furthest object that can be seen with the unaided eye.  Below M33 is the bright Milky-Way star Mirach. The image is the digital accumulation of several long exposures taken from 2018 to 2021 from Pulsnitz, Germany.", title: "The Deep Sky Toward Andromeda", url: "https://apod.nasa.gov/apod/image/2109/M31WideField_Ziegenbalg_960.jpg")
    }
    
    static var savedApod: ApodResponse {
        guard let apodRawValue = appStorage.string(forKey: "nasa_apod"),
              let apod = ApodResponse(rawValue: apodRawValue) else {
            return defaultApodResponse
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
    
    static var savedSpeedWithDate: (Speed, Date?) {
        let dateRawValue = appStorage.double(forKey: "speed_test_date")
        let date: Date? = Date(rawValue: dateRawValue)
        
        guard let speedRawValue = appStorage.string(forKey: "net_speed"),
              let speed = Speed(rawValue: speedRawValue)
        else {
            return (UserDefaults.defaultSpeed, nil)
        }
        
        return (speed, date)
    }
    
    static var savedSpeedWithPing: (Int, Speed) {
        let speed = savedSpeed
        let ping = appStorage.integer(forKey: "speed_ping")
        
        return (ping, speed)
    }
    
    static func saveNewPing(_ ping: Int) {
        appStorage.setValue(ping, forKey: "speed_ping")
    }
    
    static func saveNewSpeed(speed: Speed, at date: Date) {
        self.saveNewSpeed(speed)
        appStorage.setValue(date.rawValue, forKey: "speed_test_date")
    }
    
    static func saveNewSpeedWithPing(ping: Int, speed: Speed) {
        self.saveNewSpeed(speed)
        appStorage.setValue(ping, forKey: "speed_ping")
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
        appStorage.set(newQuote.rawValue, forKey: "quote")
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
