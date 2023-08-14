//
//  BhagwatGitaResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 07/08/23.
//

import Foundation

class BhagvatGitaResponse: Codable, RawRepresentable {
    let chapterNo: Int
    let shlokNo: Int
    let shlok: String
    let englishTranslation: String
    let hindiTranslation: String
    let englishAuthor: String
    let hindiAuthor: String
    
    init(chapterNo: Int, shlokNo: Int, shlok: String, englishTranslation: String, hindiTranslation: String, englishAuthor: String, hindiAuthor: String) {
        self.chapterNo = chapterNo
        self.shlokNo = shlokNo
        self.shlok = shlok
        self.englishTranslation = englishTranslation
        self.hindiTranslation = hindiTranslation
        self.englishAuthor = englishAuthor
        self.hindiAuthor = hindiAuthor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chapterNo = try container.decode(Int.self, forKey: .chapterNo)
        self.shlokNo = try container.decode(Int.self, forKey: .shlokNo)
        self.shlok = try container.decode(String.self, forKey: .shlok)
        self.englishTranslation = try container.decode(String.self, forKey: .englishTranslation)
        self.hindiTranslation = try container.decode(String.self, forKey: .hindiTranslation)
        self.englishAuthor = try container.decode(String.self, forKey: .englishAuthor)
        self.hindiAuthor = try container.decode(String.self, forKey: .hindiAuthor)
    }
    
    required init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(BhagvatGitaResponse.self, from: data)
        else {
            return nil
        }
        self.englishAuthor = value.englishAuthor
        self.englishTranslation = value.englishTranslation
        self.hindiAuthor = value.hindiAuthor
        self.hindiTranslation = value.hindiTranslation
        self.chapterNo = value.chapterNo
        self.shlok = value.shlok
        self.shlokNo = value.shlokNo
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.chapterNo, forKey: .chapterNo)
        try container.encode(self.shlokNo, forKey: .shlokNo)
        try container.encode(self.shlok, forKey: .shlok)
        try container.encode(self.englishTranslation, forKey: .englishTranslation)
        try container.encode(self.hindiTranslation, forKey: .hindiTranslation)
        try container.encode(self.englishAuthor, forKey: .englishAuthor)
        try container.encode(self.hindiAuthor, forKey: .hindiAuthor)
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    enum CodingKeys: String, CodingKey {
        case chapterNo = "chapter_no"
        case shlokNo = "shlok_no"
        case shlok = "shlok"
        case englishTranslation = "english_translation"
        case hindiTranslation = "hindi_translation"
        case englishAuthor = "english_author"
        case hindiAuthor = "hindi_author"
    }
}


// static data
extension BhagvatGitaResponse {
    static func getShlokas() -> [BhagvatGitaResponse] {
        let shlokaUrl = Bundle.main.url(forResource: "Shlokas", withExtension: "json")
        
        guard let shlokaUrl = shlokaUrl,
              let data = try? Data(contentsOf: shlokaUrl),
              let shlokaList = try? JSONDecoder().decode([BhagvatGitaResponse].self, from: data)
        else {
            print("No data")
            return [UserDefaults.defaultBhagvadGitaResponse]
        }
        
        return shlokaList
    }
}
