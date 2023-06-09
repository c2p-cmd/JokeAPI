//
//  Request.swift
//  Ex
//
//  Created by Sharan Thakur on 04/06/23.
//

import Foundation

public func getOrFetchRandomJoke(
    from url: String = "https://v2.jokeapi.dev/joke/Any?format=txt",
    completionHandler: @escaping ((Result<String, Error>) -> Void)
) {
    let url = URL(string: url)!
    let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {
        (data, _, err) in
        
        if let data = data {
            let joke = String(decoding: data, as: UTF8.self)
            UserDefaults.saveNewJoke(joke)
            completionHandler(.success(joke))
        }
        
        if let err = err {
            completionHandler(.failure(err))
        }
    }
    task.resume()
}

public func getRandomJoke(
    from url: String = "https://v2.jokeapi.dev/joke/Any?format=txt"
) async -> Result<String, Error> {
    do {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let joke = String(decoding: data, as: UTF8.self)
        UserDefaults.saveNewJoke(joke)
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}
