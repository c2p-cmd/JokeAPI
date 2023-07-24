//
//  Request.swift
//  Ex
//
//  Created by Sharan Thakur on 04/06/23.
//

import Foundation
import UIKit

let jokeCategories: Set<IdentifiableString> = Set([
    IdentifiableString(string: "Pun"),
    IdentifiableString(string: "Spooky"),
    IdentifiableString(string: "Christmas"),
    IdentifiableString(string: "Dark"),
    IdentifiableString(string: "Misc"),
    IdentifiableString(string: "Programming")
])

let allAnimalSubreddits: Set<IdentifiableString> = Set([
    "cute",
    "animal",
    "animalsbeingderps",
    "cuteanimals",
    "cuteanimalstogether",
    "cuteanimalflufffluffs"
].map { IdentifiableString(string: $0) })

let allMemeSubreddits: Set<IdentifiableString> = Set([
    "memes",
    "meme",
    "cleanmemes",
    "bikinibottomtwitter",
    "historymemes",
    "ComedyCemetery",
    "wholesomememes"
].map { IdentifiableString(string: $0) })

// MARK: - Loading the config.plist
var configPlist: NSDictionary = {
    let configPlistLink = Bundle.main.path(forResource: "Config", ofType: "plist")!
    return NSDictionary(contentsOfFile: configPlistLink)!
}()

// MARK: - Pickup Lines API
func getPickupLine(
    completion: ((Result<String, Error>) -> Void)?
) {
    let urlString = [configPlist.value(forKey: "Pickupline Vercel API LINK") as! String, configPlist.value(forKey: "Pickupline Vercel API LINK") as! String].randomElement()!
    
    guard let url = URL(string: urlString) else {
        completion?(.failure(URLError(.badURL)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data {
            if url.absoluteString.contains("vercel") {
                do {
                    let flirtyLine = try JSONDecoder().decode(FlirtyLineModel.self, from: data)
                    completion?(.success(flirtyLine.pickup))
                } catch {
                    completion?(.failure(error))
                }
            } else {
                let line = String(decoding: data, as: UTF8.self)
                
                completion?(.success(line))
            }
        }
        
        if let error {
            completion?(.failure(error))
        }
    }
    
    task.resume()
}


// MARK: - Get MEME Image
func getMeme(
    id: String,
    text: [String],
    completion: ((Result<UIImage, Error>) -> Void)?
) {
    let size = "?width=800&height=800"
    var urlString = configPlist.value(forKey: "MemeGen Link") as! String
    
    urlString.append("\(id)/\(text.joined()).png\(size)")
    
    guard let url = URL(string: urlString) else {
        completion?(.failure(URLError(.badURL)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data,
           let uiImage = UIImage(data: data) {
            completion?(.success(uiImage))
        }
        
        if let error {
            completion?(.failure(error))
        }
    }
    
    task.resume()
}

// MARK: - Meme Generator
func getMemeTemplates() async -> Result<[MemeTemplate], Error> {
    let urlString = configPlist.value(forKey: "MemeGen Templates") as! String
    
    guard let url = URL(string: urlString) else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let templates = try JSONDecoder().decode([MemeTemplate].self, from: data)
        
        return .success(templates)
    } catch {
        return .failure(error)
    }
}

// MARK: - Reddit Scrapper API (List)
func getRedditMemes(
    from subreddit: String,
    _ count: Int = 2
) async -> Result<MemeList, Error> {
    var count = count
    if count <= 1 {
        count = 2
    }
    if count > 10 {
        count = 10
    }
    
    var urlString = configPlist.value(forKey: "REDDIT MEME Link") as! String
    urlString.append("/\(subreddit)/\(count)/")
    
    guard let url = URL(string: urlString) else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let redditMemeResponse = try JSONDecoder().decode(RedditMemeList.self, from: data)
        let memes = redditMemeResponse.memes
        
        return .success(memes)
    } catch {
        return .failure(error)
    }
}

// MARK: - Reddit Scrapper API
func getRedditMeme(
    from subreddit: String
) async -> Result<RedditMemeResponse, Error> {
    var urlString = configPlist.value(forKey: "REDDIT MEME Link") as! String
    urlString.append("/\(subreddit)")
    
    guard let url = URL(string: urlString) else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let redditMemeResponse = try JSONDecoder().decode(RedditMemeResponse.self, from: data)
        
        let (image, didSuccess) = await fetchURLImage(from: URL(string: redditMemeResponse.url)!)
        
        if didSuccess {
            redditMemeResponse.uiImage = image.resizedForWidget
        }
        
        return .success(redditMemeResponse)
    } catch {
        return .failure(error)
    }
}

// MARK: - NASA APOD API
func getNASAApod(on date: Date? = nil) async -> Result<ApodResponse, Error> {
    let urlString = configPlist.value(forKey: "NASA APOD Link") as! String
    let apiKey = configPlist.value(forKey: "NASA API KEY") as! String
    
    var finalUrl = "\(urlString)?api_key=\(apiKey)"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    if let date = date {
        finalUrl = finalUrl.appending("&date=\(dateFormatter.string(from: date))")
    }
    
    guard let url = URL(string: finalUrl) else {
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
    type jokeType: JokeType,
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
        urlString.append(format)
        
        if jokeType != .any {
            urlString.append("&type=\(jokeType.rawValue)")
        }
        
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let joke = String(decoding: data, as: UTF8.self)
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}

// helper
fileprivate func fetchURLImage(
    from url: URL
) async -> (UIImage, Bool) {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let image = UIImage(data: data) {
            return (image, true)
        } else {
            return (UIImage(systemName: "exclamationmark.triangle.fill")!, false)
        }
    } catch {
        print(error.localizedDescription)
        return (UIImage(systemName: "exclamationmark.triangle.fill")!, false)
    }
}
