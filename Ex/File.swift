//
//  File.swift
//  Ex
//
//  Created by Sharan Thakur on 09/06/23.
//

import Foundation

struct QuoteApiResponse: Codable {
    let content: String
    let author: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.content = try values.decode(String.self, forKey: .content)
        self.author = try values.decode(String.self, forKey: .author)
    }
    
    init(
        _ content: String,
        by author: String
    ) {
        self.content = content
        self.author = author
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case author
    }
}

extension QuoteApiResponse: RawRepresentable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(QuoteApiResponse.self, from: data)
        else {
            return nil
        }
        self = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.author, forKey: .author)
    }
}


// MARK: - UserDefaults Quote Extension
extension UserDefaults {
    static let defaultQuote = QuoteApiResponse("Much wisdom often goes with fewest words.", by: "Sophocles")
    
    static var savedQuote: QuoteApiResponse {
        (UserDefaults.standard.object(forKey: "quote") as? QuoteApiResponse) ?? UserDefaults.defaultQuote
    }
    
    static func saveNewQuote(
        _ newQuote: QuoteApiResponse
    ) {
        UserDefaults.standard.set(newQuote.content, forKey: "quote")
    }
}

// MARK: - UserDefaults Joke Extension
extension UserDefaults {
    static let defaultJoke = "Why do Java Programmers have to wear glasses?\n\nBecause they don't C#."
    
    static var savedJoke: String {
        UserDefaults.standard.string(forKey: "save_joke") ?? UserDefaults.defaultJoke
    }
    
    static func saveNewJoke(
        _ newJoke: String
    ) {
        UserDefaults.standard.set(newJoke, forKey: "save_joke")
    }
}
