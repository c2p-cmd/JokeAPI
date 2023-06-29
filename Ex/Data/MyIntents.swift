//
//  MyIntents.swift
//  Ex
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents

struct QuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Quote To"
    
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
    static var title: LocalizedStringResource = "Set Joke To"
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let jokeRes = await getRandomJoke(of: [], safeMode: true)
        
        switch jokeRes {
        case .success(let newJoke):
            appStorage.setValue(newJoke, forKey: "joke")
            return .result(value: newJoke)
        case .failure(let err):
            return .result(value: err.localizedDescription)
        }
    }
}
