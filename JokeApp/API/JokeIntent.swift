//
//  JokeIntent.swift
//  JokeApp
//
//  Created by kida-macbook-air on 27/06/23.
//

import AppIntents

struct JokeIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Joke To"
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let jokeRes = await getRandomJoke()
        
        switch jokeRes {
        case .success(let newJoke):
            appStorage.setValue(newJoke, forKey: "joke")
            return .result(value: newJoke)
        case .failure(let err):
            return .result(value: err.localizedDescription)
        }
    }
}
