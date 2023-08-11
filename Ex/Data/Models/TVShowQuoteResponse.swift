//
//  TVShowQuoteResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 11/08/23.
//

import Foundation

// MARK: - TVShowQuoteResponseElement
class TVShowQuoteResponse: Codable, RawRepresentable, Identifiable {
    let id: UUID = UUID()
    let show: String
    let character: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case character = "character"
        case text = "text"
    }
    
    init(show: String, character: String, text: String) {
        self.show = show
        self.character = character
        self.text = text
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.show = try container.decode(String.self, forKey: .show)
        self.character = try container.decode(String.self, forKey: .character)
        self.text = try container.decode(String.self, forKey: .text)
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(TVShowQuoteResponse.self, from: data)
        else {
            return nil
        }
        self.character = value.character
        self.show = value.show
        self.text = value.text
    }
    
    var description: String {
        "\(character), \(show)"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.show, forKey: .show)
        try container.encode(self.character, forKey: .character)
        try container.encode(self.text, forKey: .text)
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
}

extension TVShowQuoteResponses {
    var string: [String] {
        map { $0.description }
    }
    
    static var allShows: [String] {
        [
            "How I Met Your Mother",
            "The Middle",
            "New Girl",
            "Suits",
            "3rd Rock from the Sun",
            "Arrested Development",
            "Malcolm in the Middle",
            "Monk",
            "The Fresh Prince of Bel-Air",
            "Parks And Recreation",
            "Home Improvement",
            "Cheers",
            "Modern Family",
            "Seinfeld",
            "The Office",
            "The Goldbergs",
            "Gilmore Girls",
            "Frasier",
            "Breaking Bad",
            "Scrubs",
            "Boy Meets World",
            "Everybody Loves Raymond",
            "The Good Place",
            "Brooklyn Nine-Nine",
            "Everybody Hates Chris",
            "Lucifer",
            "Schitt's Creek",
            "Derry Girls",
            "Friends",
            "Stranger Things",
            "The Golden Girls"
        ].sorted { $1 > $0 }
    }
    
    static var defaultResponse: TVShowQuoteResponse {
        TVShowQuoteResponse(
            show: "Friends",
            character: "Phoebe",
            text: "They don't know that we know that they know."
        )
    }
    
    static func getSavedQuotes() -> TVShowQuoteResponses {
        let quotes = Bundle.main.url(forResource: "TVShowQuotes", withExtension: "json")
        guard let quotes else {
            print("No url")
            return [defaultResponse]
        }
        guard let data = try? Data(contentsOf: quotes) else {
            print("No data")
            return [defaultResponse]
        }
        guard let tvShowQuoteResponses = try? JSONDecoder().decode(TVShowQuoteResponses.self, from: data) else {
            print("No data")
            return [defaultResponse]
        }
        
        return tvShowQuoteResponses
    }
}

typealias TVShowQuoteResponses = [TVShowQuoteResponse]

