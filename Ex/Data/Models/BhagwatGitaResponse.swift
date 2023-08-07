//
//  BhagwatGitaResponse.swift
//  Ex
//
//  Created by Sharan Thakur on 07/08/23.
//

import Foundation

class BhagvatGitaResponse: Codable {
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
func getShlokas() -> [BhagvatGitaResponse] {
    let shlokaUrl = Bundle.main.url(forResource: "Shlokas", withExtension: "json")
    guard let shlokaUrl else {
        print("No url")
        return [firstResponse]
    }
    guard let data = try? Data(contentsOf: shlokaUrl) else {
        print("NO data")
        return [firstResponse]
    }
    guard let shlokaList = try? JSONDecoder().decode([BhagvatGitaResponse].self, from: data) else {
        print("No data")
        return [firstResponse]
    }
    
    return shlokaList
}
