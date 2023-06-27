//
//  Requests.swift
//  JokeApp
//
//  Created by kida-macbook-air on 27/06/23.
//

import Foundation

let appStorage = UserDefaults(suiteName: "group.kida")!

fileprivate let url = URL(string: "https://v2.jokeapi.dev/joke/Any?format=txt")!

//enum JokeType { case single; case twopart; case random }
//
//class JokeCategory {
//    static let random = JokeCategory(category: "Any")
//    static let programming = JokeCategory(category: "Programming")
//    static let misc = JokeCategory(category: "Misc")
//    static let dark = JokeCategory(category: "Dark")
//    static let pun = JokeCategory(category: "Pun")
//    static let spooky = JokeCategory(category: "Spooky")
//    static let christmas = JokeCategory(category: "Christmas")
//    
//    var category: String = "Any"
//    
//    private init(category: String) {
//        self.category = category
//    }
//}

func getRandomJoke() async -> Result<String, Error> {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let joke = String(data: data, encoding: .utf8) else {
            return .failure(CustomError("Data is null!"))
        }
        
        return .success(joke)
    } catch (let err) {
        return .failure(err)
    }
}

struct CustomError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
