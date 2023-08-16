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


// MARK: - NextMCUFilm API
func getNextMCUFilm(
    on date: Date? = nil,
    completion: @escaping (Result<NextMcuFilm, Error>) -> Void
) {
    let urlString = configPlist.value(forKey: "NEXT MCU FILM API LINK") as! String
    guard var url = URL(string: urlString) else {
        completion(.failure(URLError(.badURL)))
        return
    }
    
    if let date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = dateFormatter.string(from: date)
        let dateQueryItem = URLQueryItem(name: "date", value: dateString)
        
        url.append(queryItems: [dateQueryItem])
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error {
            completion(.failure(error))
        }
        
        if let data {
            do {
                let response = try JSONDecoder().decode(NextMcuFilm.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }.resume()
}


// MARK: - BhagwatGita API
func getBhagvadGitaShloka() async -> Result<BhagvatGitaResponse, Error> {
    let deviceId: String? = await UIDevice.current.identifierForVendor?.uuidString
    let urlString = "https://7c8b-219-91-171-119.ngrok-free.app/bhagvadgita/\(deviceId ?? "nil")/"
    
    guard let url = URL(string: urlString) else {
        let error = NetworkError(message: "Bad URL")
        return .failure(error)
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let bhagvadGitaResponse = try JSONDecoder().decode(BhagvatGitaResponse.self, from: data)
        
        return .success(bhagvadGitaResponse)
    } catch {
        return .failure(error)
    }
}

// MARK: - BhagwatGita API
func getBhagvadGitaShloka(
    completion: @escaping (BhagvatGitaResponse?, Error?) -> Void
) {
    let deviceId: String? = UIDevice.current.identifierForVendor?.uuidString
    let urlString = "https://7c8b-219-91-171-119.ngrok-free.app/bhagvadgita/\(deviceId ?? "nil")/"
    
    guard let url = URL(string: urlString) else {
        let error = NetworkError(message: "Bad URL")
        completion(nil, error)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data {
            do {
                print(String(decoding: data, as: UTF8.self))
                let response = try JSONDecoder().decode(BhagvatGitaResponse.self, from: data)
                completion(response, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        if let error {
            completion(nil, error)
        }
    }.resume()
}


// MARK: - TV Show Quote
func getTVShowQuote(
    from tvShow: String = TVShowQuoteResponses.allShows.randomElement()!,
    count: Int = 1,
    keepShort: Bool = true
) async -> TVShowQuoteResponses {
    var urlString = configPlist.value(forKey: "TV Show Quotes") as! String
    urlString.append("/\(count)")
    let queryItems = [
        URLQueryItem(name: "show", value: tvShow),
        URLQueryItem(name: "short", value: keepShort.description)
    ]
    guard let url = URL(string: urlString)?.appending(queryItems: queryItems) else {
        fatalError(URLError(.badURL).localizedDescription)
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let newResponses: TVShowQuoteResponses = try JSONDecoder().decode(TVShowQuoteResponses.self, from: data)
        
        return newResponses
    } catch {
        print(error.localizedDescription)
        var savedResponses = TVShowQuoteResponses.getSavedQuotes()
        savedResponses.shuffle()
        
        return savedResponses
    }
}

// MARK: - TV Show Quote with closure
func getTVShowQuote(
    from tvShow: String = TVShowQuoteResponses.allShows.randomElement()!,
    count: Int = 1,
    keepShort: Bool = true,
    completion: @escaping (TVShowQuoteResponses, Error?) -> Void
) {
    var urlString = configPlist.value(forKey: "TV Show Quotes") as! String
    urlString.append("/\(count)")
    let queryItems = [
        URLQueryItem(name: "show", value: tvShow),
        URLQueryItem(name: "short", value: "\(keepShort)")
    ]
    guard let url = URL(string: urlString)?.appending(queryItems: queryItems) else {
        fatalError(URLError(.badURL).localizedDescription)
    }
    
//    print(url.absoluteString)
    
    URLSession.shared.dataTask(with: url) { (data: Data?, _: URLResponse?, error: Error?) in
        var savedResponses = UserDefaults.savedTVShowQuotes
        savedResponses.shuffle()
        
        if let data {
            if let newResponses = try? JSONDecoder().decode(TVShowQuoteResponses.self, from: data) {
                completion(newResponses, nil)
            } else {
                completion(savedResponses, NetworkError(message: "Data not decoded"))
            }
        }
        
        if let error {
//            print(error.localizedDescription)
            completion(savedResponses, error)
        }
    }.resume()
}


// MARK: - NumberAPI DATE
func getFactAboutDate(
    month: Int,
    day: Int,
    completion: @escaping (String?, Error?) -> Void
) {
    let urlString = NumberAPI.date(month: month, day: day)
    
    guard let url = URL(string: urlString) else {
        completion(nil, URLError(.badURL))
        return
    }
    
    numberAPIHelper(url, completion: completion)
}

func getFactAboutDate(
    formattedDate: String,
    completion: @escaping (String?, Error?) -> Void
) {
    let urlString = NumberAPI.date(formattedDate: formattedDate)
    
    guard let url = URL(string: urlString) else {
        completion(nil, URLError(.badURL))
        return
    }
    
    numberAPIHelper(url, completion: completion)
}

// MARK: - NumberAPI Year
func getFactAboutYear(
    year: Int,
    completion: @escaping (String?, Error?) -> Void
) {
    let urlString = NumberAPI.year(year)
    
    guard let url = URL(string: urlString) else {
        completion(nil, URLError(.badURL))
        return
    }
    
    numberAPIHelper(url, completion: completion)
}

// MARK: - NumberAPI Number
func getFactAboutNumber(
    _ number: Int,
    completion: @escaping (String?, Error?) -> Void
) {
    let urlString = NumberAPI.random(num: number)
    
    guard let url = URL(string: urlString) else {
        completion(nil, URLError(.badURL))
        return
    }
    
    numberAPIHelper(url, completion: completion)
}

// MARK: - Number api helper
fileprivate func numberAPIHelper(
    _ url: URL,
    completion: @escaping (String?, Error?) -> Void
) {
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        if let data {
            let fact = String(decoding: data, as: UTF8.self)
            completion(fact, nil)
        }
        
        if let error {
            completion(nil, error)
        }
    }
    
    task.resume()
}

// MARK: - Pickup Lines API
func getPickupLine() async -> Result<String, Error> {
    let urlString = [configPlist.value(forKey: "Pickup API LINK ANOTHER") as! String, configPlist.value(forKey: "Pickupline Vercel API LINK") as! String].randomElement()!
    
    guard let url = URL(string: urlString) else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if url.absoluteString.contains("vercel") {
            let flirtyLine = try JSONDecoder().decode(FlirtyLineModel.self, from: data)
            return .success(flirtyLine.pickup)
        } else {
            let pickUpLine = String(decoding: data, as: UTF8.self)
            return .success(pickUpLine)
        }
    } catch {
        return .failure(error)
    }
}

func getPickupLine(
    completion: @escaping (Result<String, Error>) -> Void
) {
    let urlString = [configPlist.value(forKey: "Pickupline Vercel API LINK") as! String, configPlist.value(forKey: "Pickup API LINK ANOTHER") as! String].randomElement()!
    
    guard let url = URL(string: urlString) else {
        completion(.failure(URLError(.badURL)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data {
            if url.absoluteString.contains("vercel") {
                do {
                    let flirtyLine = try JSONDecoder().decode(FlirtyLineModel.self, from: data)
                    completion(.success(flirtyLine.pickup))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let line = String(decoding: data, as: UTF8.self)
                
                completion(.success(line))
            }
        }
        
        if let error {
            completion(.failure(error))
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
    let size = "?width=800&height=800/"
    var urlString = configPlist.value(forKey: "MemeGen Link") as! String
    
    urlString.append("\(id)/\(text.joined()).png\(size)")
    
    print(urlString)
    
    guard let url = URL(string: urlString) else {
        completion?(.failure(URLError(.badURL)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let data = data,
           let uiImage = UIImage(data: data) {
            completion?(.success(uiImage))
        }
        
        if let response = response as? HTTPURLResponse {
            print(response.description)
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
        
        let imageData = try Data(contentsOf: URL(string: redditMemeResponse.url)!)
        
        if let image = UIImage(data: imageData) {
            redditMemeResponse.uiImage = image
            print("Yayyie")
        } else {
            print("nein!")
        }
        
//        let (image, didSuccess) = await fetchURLImage(from: URL(string: redditMemeResponse.url)!)
//        
//        if didSuccess {
//            redditMemeResponse.uiImage = image.resizedForWidget
//        }
        
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
        let (data, _) = try await URLSession.shared.data(from: url)
        
//#if DEBUG
//        if let httpResponse = response as? HTTPURLResponse {
//            print(httpResponse.debugDescription)
//        }
//#endif
        
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
        
        if joke.starts(with: "Error") {
            return .failure(CustomIntentError("No jokes in category"))
        }
        
        return .success(joke)
    } catch let err {
        return .failure(err)
    }
}

func getRandomJoke(
    of category: String,
    type jokeType: JokeType,
    safeMode: Bool = false
) async -> Result<String, Error> {
    do {
        var urlString = configPlist.value(forKey: "Joke URL") as! String
        
        if category.isEmpty || category == "Any" {
            urlString.append("Any")
        } else {
            urlString.append(category)
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
        
        if joke.starts(with: "Error") {
            return .failure(CustomIntentError("No jokes in category"))
        }
        
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
