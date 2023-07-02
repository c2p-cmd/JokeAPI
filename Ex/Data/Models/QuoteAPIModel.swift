//
//  Model.swift
//  Ex
//
//  Created by Sharan Thakur on 29/06/23.
//

import Foundation

// MARK: - API Model
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

// MARK: - To use in @AppStorage wrapper
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
