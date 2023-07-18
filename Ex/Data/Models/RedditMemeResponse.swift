//
//  PexelsPhotoResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 13/07/23.
//

import Foundation
import UIKit

typealias MemeList = [RedditMemeResponse]

// MARK: - RedditMemeList
class RedditMemeList: Codable, RawRepresentable {
    let memes: MemeList
    
    init(memes: MemeList) {
        self.memes = memes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.memes = try container.decode(MemeList.self, forKey: .memes)
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        
        self.memes = value.memes
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
        
        try container.encode(self.memes, forKey: .memes)
    }
    
    enum CodingKeys: String, CodingKey {
        case memes
    }
}

// MARK: - RedditMemeResponse
class RedditMemeResponse: Codable, RawRepresentable {
    let title: String
    let url: String
    let nsfw: Bool
    var uiImage: UIImage?
    
    init(title: String, url: String, nsfw: Bool) {
        self.title = title
        self.url = url
        self.nsfw = nsfw
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(RedditMemeResponse.self, from: data)
        else {
            return nil
        }
        self.nsfw = value.nsfw
        self.title = value.title
        self.url = value.url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.nsfw = try container.decode(Bool.self, forKey: .nsfw)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        
        if let data = try container.decodeIfPresent(Data.self, forKey: .uiImage) {
            self.uiImage = UIImage(data: data)
        }
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
        
        try container.encode(self.nsfw, forKey: .nsfw)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.url, forKey: .url)
        
        if let pngData = self.uiImage?.pngData() {
            try container.encodeIfPresent(pngData, forKey: .uiImage)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case nsfw
        case uiImage
    }
}
