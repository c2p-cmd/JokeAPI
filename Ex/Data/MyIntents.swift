//
//  MyIntents.swift
//  Ex
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents

struct QuoteIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch New Quote")
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let quoteResult = await getRandomQuote()
        
        switch quoteResult {
        case .success(let quoteResponse):
            UserDefaults.saveNewQuote(quoteResponse)
            return .result(value: quoteResponse.content)
        case .failure(_):
            return .result(value: UserDefaults.savedQuote.content)
        }
    }
}

struct JokeIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch New Joke")
    
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
