//
//  Requests.swift
//  JokeApp
//
//  Created by kida-macbook-air on 27/06/23.
//

import Foundation

let appStorage = UserDefaults(suiteName: "group.kida")!

fileprivate let url = URL(string: "https://v2.jokeapi.dev/joke/Any?format=txt")!

func getRandomJoke() async -> Result<String, Error> {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let joke = String(decoding: data, as: UTF8.self)
        return .success(joke)
    } catch (let err) {
        return .failure(err)
    }
}
