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
    
    //    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let quoteResult = await getRandomQuote()
        
        switch quoteResult {
        case .success(let quoteResponse):
            UserDefaults.saveNewQuote(quoteResponse)
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
    
    //    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let jokeRes = await getRandomJoke(of: [], type: .twopart, safeMode: true)
        
        switch jokeRes {
        case .success(let newJoke):
            UserDefaults.saveNewJoke(newJoke)
            return .result(value: newJoke)
        case .failure(_):
            return .result(value: UserDefaults.savedJoke)
        }
    }
}

struct SpeedTestIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch Latest Download Speed")
    
    //    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let downloadService = DownloadService.shared
        
        let res = await downloadService.testWithPing(for: url, in: 60)
        
        switch res {
        case .success(let (newPing, newSpeed)):
            UserDefaults.saveNewSpeedWithPing(ping: newPing, speed: newSpeed)
            return .result(value: "At a ping of \(newPing) the speed is \(newSpeed.description)")
        case .failure(_):
            let (oldPing, oldSpeed) = UserDefaults.savedSpeedWithPing
            return .result(value: "At a ping of \(oldPing) the speed is \(oldSpeed.description)")
        }
    }
}


struct FlirtyLinesIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Flirt with me ;-)")
    
    //    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let result = await getPickupLine()
        
        switch result {
        case .success(let newLine):
            UserDefaults.saveNewFlirtyLine(newLine)
            return .result(value: newLine)
        case .failure(_):
            return .result(value: UserDefaults.savedFlirtyLine)
        }
    }
}

struct TVShowQuoteAppIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Get TV Show Quote")
    
    init() {
        self.keepShort = true
    }
    
    init(keepShort: Bool) {
        self.keepShort = keepShort
    }
    
    @Parameter(title: "ShortQuote", default: true)
    var keepShort: Bool
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let tvShowQuote = await getTVShowQuote(count: 1, keepShort: false).randomElement()!
        
        let responseString = """
From the show: \"\(tvShowQuote.show)\",
\"\(tvShowQuote.character)\" says.
\(tvShowQuote.text)
"""
        
        return .result(value: responseString)
    }
}
