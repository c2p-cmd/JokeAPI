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
    
    static var openAppWhenRun: Bool = true
    
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
    
    static var openAppWhenRun: Bool = true
    
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
    
    static var openAppWhenRun: Bool = true
    
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
    
    static var openAppWhenRun: Bool = true
    
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

struct HTTPAnimalIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "HTPP Status with picture of cat or dog")
    
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Choice between cat or dog")
    var animalChoice: AnimalChoice
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let res = await fetchAnimalImage(of: self.animalChoice)
        
        return .result(value: "Here is a picture of a \(self.animalChoice)") {
            Image(uiImage: res)
                .resizable()
                .scaledToFit()
        }
    }
}

struct CuteAnimalPictureIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Fetch a cute animal picture!")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue {
        let result = await getRedditMeme(from: allAnimalSubreddits.randomElement()!.string)
        
        switch result {
        case .success(let response):
            return .result(value: response.title) {
                return AsyncImage(url: URL(string: response.url)) {
                    $0.resizable()
                } placeholder: {
                    Image(Bool.random() ? "black_cat" : "happy_dog")
                }.scaledToFill()
            }
        case .failure(_):
            break
        }
        
        let savedResponse = UserDefaults.savedRedditAnimalResponse
        
        return .result(value: savedResponse.title) {
            AsyncImage(url: URL(string: savedResponse.url)) {
                $0.resizable()
            } placeholder: {
                Image(Bool.random() ? "black_cat" : "happy_dog")
            }
        }
    }
}
