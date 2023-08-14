//
//  MyIntents.swift
//  Ex
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents
import SwiftUI

struct QuoteIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch New Quote")
    static var description: IntentDescription? = IntentDescription(stringLiteral: "This is an intent to fetch a new quote")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let quoteResult = await getRandomQuote()
        
        switch quoteResult {
        case .success(let quoteResponse):
            let reply = "Once \(quoteResponse.author) said. \(quoteResponse.content)"
            return .result(value: reply)
        case .failure(_):
            let quoteResponse = UserDefaults.savedQuote
            let reply = "Once \(quoteResponse.author) said. \(quoteResponse.content)"
            return .result(value: reply)
        }
    }
}

struct JokeIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch New Joke")
    static var description: IntentDescription? = IntentDescription(stringLiteral: "This is an intent to fetch a new joke")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let jokeRes = await getRandomJoke(of: [], type: .twopart, safeMode: true)
        
        switch jokeRes {
        case .success(let newJoke):
            return .result(value: newJoke)
        case .failure(_):
            return .result(value: UserDefaults.savedJoke)
        }
    }
}

struct SpeedTestIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch Latest Download Speed")
    static var description: IntentDescription? = IntentDescription(stringLiteral: "This is an intent to test internet speed")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let downloadService = DownloadService.shared
        
        let res = await downloadService.test(for: url, in: 60)
        
        switch res {
        case .success(let newSpeed):
            return .result(value: "The speed is \(newSpeed.description)")
        case .failure(_):
            return .result(value: "Sorry! you seem to be offline")
        }
    }
}


struct FlirtyLinesIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Flirt with me ;-)")
    static var description: IntentDescription? = IntentDescription(stringLiteral: "This is an intent to fetch a pick up line")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let result = await getPickupLine()
        
        switch result {
        case .success(let newLine):
            return .result(value: newLine)
        case .failure(_):
            return .result(value: UserDefaults.savedFlirtyLine)
        }
    }
}

struct TVShowQuoteAppIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Get TV Show Quote")
    static var description: IntentDescription? = IntentDescription(stringLiteral: "This is an intent to fetch a Quote from a TV Show")
    
    @Parameter(title: "ShortQuote", default: true)
    var keepShort: Bool
    
    init() {
        self.keepShort = true
    }
    
    init(keepShort: Bool) {
        self.keepShort = keepShort
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let tvShowQuote = await getTVShowQuote(count: 1, keepShort: self.keepShort).randomElement()!
        
        let responseString = """
From the show: \"\(tvShowQuote.show)\",
\"\(tvShowQuote.character)\" says.
\(tvShowQuote.text)
"""
        
        return .result(value: responseString)
    }
}
