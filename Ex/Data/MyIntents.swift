//
//  MyIntents.swift
//  Ex
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents

struct QuoteIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Set Quote To")
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let quoteResult = await getRandomQuote()
        
        switch quoteResult {
        case .success(let quoteResponse):
            UserDefaults.saveNewQuote(quoteResponse)
            return .result(value: quoteResponse.content)
        case .failure(let error):
            return .result(value: error.localizedDescription)
        }
    }
}

struct JokeIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Set Joke To")
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let jokeRes = await getRandomJoke(of: [], type: .twopart, safeMode: true)
        
        switch jokeRes {
        case .success(let newJoke):
            UserDefaults.saveNewJoke(newJoke)
            return .result(value: newJoke)
        case .failure(let err):
            return .result(value: err.localizedDescription)
        }
    }
}

@available(iOS 16, *)
struct SpeedTestIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "SpeedTestingIntent")
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let downloadService = DownloadService.shared
        
        let res = await downloadService.test(for: url, in: 60)
        
        switch res {
        case .success(let speed):
            UserDefaults.saveNewSpeed(speed)
            return .result(value: speed.description)
        case .failure(let err):
            return .result(value: err.localizedDescription)
        }
    }
}

