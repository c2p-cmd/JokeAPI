//
//  NASAApodResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 11/07/23.
//

import UIKit
import Foundation

// MARK: - ApodResponse with AppStorage wrapper
struct ApodResponse: Codable, RawRepresentable {
    let date, explanation: String
    let title: String
    let url: String
    var uiImage: UIImage?

    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case title
        case url
        case uiImage
    }
    
    init(date: String, explanation: String, title: String, url: String) {
        self.date = date
        self.explanation = explanation
        self.title = title
        self.url = url
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(ApodResponse.self, from: data)
        else {
            return nil
        }
        self = value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try values.decode(String.self, forKey: .date)
        self.explanation = try values.decode(String.self, forKey: .explanation)
        self.url = try values.decode(String.self, forKey: .url)
        self.title = try values.decode(String.self, forKey: .title)
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.explanation, forKey: .explanation)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.url, forKey: .url)
    }
}

