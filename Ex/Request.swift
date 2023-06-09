//
//  Request.swift
//  Ex
//
//  Created by Sharan Thakur on 04/06/23.
//

import Foundation

public func getRandomJoke(
    from url: String = "https://v2.jokeapi.dev/joke/Any?format=txt",
    completionHandler: @escaping ((String?, Error?) -> Void)
) {
    // TODO: UserDefault and Result data type
    let url = URL(string: url)!
    let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {
        (data, _, err) in
        
        if let data = data {
            let joke = String(decoding: data, as: UTF8.self)
            completionHandler(joke, nil)
        }
        
        if let err = err {
            completionHandler(nil, err)
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
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}
