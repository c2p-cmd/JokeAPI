//
//  PexelsPhotoResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 13/07/23.
//

import Foundation

class MultiPhotoResponse: Codable, RawRepresentable {
    let photos: [PexelsPhotoResponse]
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
    
    init(photos: [PexelsPhotoResponse]) {
        self.photos = photos
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self.photos = value.photos
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.photos = try values.decode([PexelsPhotoResponse].self, forKey: .photos)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.photos, forKey: .photos)
    }
}

class PexelsPhotoResponse: Codable, RawRepresentable {
    let id, width, height: Int
    let src: Src
    let alt: String
    
    var imageUrl: URL {
        URL(string: self.src.large)!
    }
    
    enum CodingKeys: String, CodingKey {
        case id, width, height
        case src, alt
    }
    
    init(id: Int, width: Int, height: Int, src: Src, alt: String) {
        self.alt = alt
        self.id = id
        self.width = width
        self.height = height
        self.src = src
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self.src = value.src
        self.alt = value.alt
        self.height = value.height
        self.width = value.width
        self.id = value.id
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.src = try values.decode(Src.self, forKey: .src)
        self.alt = try values.decode(String.self, forKey: .alt)
        self.height = try values.decode(Int.self, forKey: .height)
        self.width = try values.decode(Int.self, forKey: .width)
        self.id = try values.decode(Int.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.src, forKey: .src)
        try container.encode(self.alt, forKey: .alt)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.id, forKey: .id)
    }
}

// MARK: - Src
class Src: Codable, RawRepresentable {
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case large
    }
    
    init(large: String) {
        self.large = large
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self.large = value.large
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.large = try values.decode(String.self, forKey: .large)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.large, forKey: .large)
    }
}
