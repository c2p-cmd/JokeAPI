//
//  Request.swift
//  Ex
//
//  Created by Sharan Thakur on 04/06/23.
//

import Foundation

let jokeCategories: Set<IdentifiableString> = Set([
    "Pun",
    "Spooky",
    "Christmas",
    "Dark",
    "Misc",
    "Programming"
].map { IdentifiableString(string: $0) })

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

func getRandomQuote() async -> Result<QuoteApiResponse, Error> {
    do {
        let quoteUrl = URL(string: "https://api.quotable.io/random")!
        let (data, _) = try await URLSession.shared.data(from: quoteUrl)
        let quoteApiResponse = try JSONDecoder().decode(QuoteApiResponse.self, from: data)
        
        return .success(quoteApiResponse)
    } catch {
        return .failure(error)
    }
}

func getRandomJoke(
    of categories: [IdentifiableString],
    safeMode: Bool = false
) async -> Result<String, Error> {
    do {
        var urlString = "https://v2.jokeapi.dev/joke/"
        
        if categories.isEmpty {
            urlString.append("Any")
        } else {
            for i in 0 ..< categories.count {
                if i == categories.count-1 {
                    urlString.append(categories[i].string)
                } else {
                    urlString.append("\(categories[i].string),")
                }
            }
        }
        
        let format = safeMode ? "?format=txt&safe-mode" : "?format=txt"
        
        let url = URL(string: "\(urlString)\(format)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let joke = String(decoding: data, as: UTF8.self)
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}
