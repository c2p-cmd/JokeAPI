//
//  Request.swift
//  Ex
//
//  Created by Sharan Thakur on 04/06/23.
//

import Foundation

let jokeCategories: Set<IdentifiableString> = Set([
    IdentifiableString(string: "Pun"),
    IdentifiableString(string: "Spooky"),
    IdentifiableString(string: "Christmas"),
    IdentifiableString(string: "Dark"),
    IdentifiableString(string: "Misc"),
    IdentifiableString(string: "Programming")
])

// MARK: - Loading the config.plist
private var configPlist: NSDictionary = {
    let configPlistLink = Bundle.main.path(forResource: "Config", ofType: "plist")!
    return NSDictionary(contentsOfFile: configPlistLink)!
}()


// MARK: - NASA APOD API
func getNASAApod() async -> Result<ApodResponse, Error> {
    let urlString = configPlist.value(forKey: "NASA APOD Link") as! String
    let apiKey = configPlist.value(forKey: "NASA API KEY") as! String
    
    guard let url = URL(string: "\(urlString)?api_key=\(apiKey)") else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.debugDescription)
        }
        #endif
        
        let apodResponse = try JSONDecoder().decode(ApodResponse.self, from: data)
        return .success(apodResponse)
    } catch {
        return .failure(error)
    }
}

// MARK: - QUOTE API
func getRandomQuote() async -> Result<QuoteApiResponse, Error> {
    do {
        let urlString = configPlist.value(forKey: "Quote URL") as! String
        let quoteUrl = URL(string: urlString)!
        let (data, _) = try await URLSession.shared.data(from: quoteUrl)
        let quoteApiResponse = try JSONDecoder().decode(QuoteApiResponse.self, from: data)
        
        return .success(quoteApiResponse)
    } catch {
        return .failure(error)
    }
}


// MARK: - JOKE API
func getRandomJoke(
    of categories: [IdentifiableString],
    safeMode: Bool = false
) async -> Result<String, Error> {
    do {
        var urlString = configPlist.value(forKey: "Joke URL") as! String
        
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
        
        guard let url = URL(string: "\(urlString)\(format)") else {
            return .failure(URLError(.badURL))
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let joke = String(decoding: data, as: UTF8.self)
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}
