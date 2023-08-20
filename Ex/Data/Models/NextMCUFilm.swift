//
//  NextMCUFilm.swift
//  Ex
//
//  Created by Sharan Thakur on 15/08/23.
//

import Foundation

// MARK: - NextMcuFilm
class NextMcuFilm: Codable, RawRepresentable {
    let daysUntil: Int
    let followingProduction: NextMcuFilm?
    let overview: String
    let posterUrl: String
    let releaseDate: String
    let title: String
    let type: String

    var theReleaseDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: self.releaseDate) {
            return date
        }
        return .now
    }
    
    init(daysUntil: Int, followingProduction: NextMcuFilm?, overview: String, posterUrl: String, releaseDate: String, title: String, type: String) {
        self.daysUntil = daysUntil
        self.followingProduction = followingProduction
        self.overview = overview
        self.posterUrl = posterUrl
        self.releaseDate = releaseDate
        self.title = title
        self.type = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.daysUntil = try container.decode(Int.self, forKey: .daysUntil)
        self.followingProduction = try container.decodeIfPresent(NextMcuFilm.self, forKey: .followingProduction)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.posterUrl = try container.decode(String.self, forKey: .posterUrl)
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        self.title = try container.decode(String.self, forKey: .title)
        self.type = try container.decode(String.self, forKey: .type)
    }
    
    required convenience init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(NextMcuFilm.self, from: data)
        else {
            return nil
        }
        self.init(daysUntil: value.daysUntil, followingProduction: value.followingProduction, overview: value.overview, posterUrl: value.posterUrl, releaseDate: value.releaseDate, title: value.title, type: value.type)
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
        try container.encode(self.daysUntil, forKey: .daysUntil)
        try container.encodeIfPresent(self.followingProduction, forKey: .followingProduction)
        try container.encode(self.overview, forKey: .overview)
        try container.encode(self.posterUrl, forKey: .posterUrl)
        try container.encode(self.releaseDate, forKey: .releaseDate)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.type, forKey: .type)
    }
    
    enum CodingKeys: String, CodingKey {
        case daysUntil = "days_until"
        case followingProduction = "following_production"
        case overview = "overview"
        case posterUrl = "poster_url"
        case releaseDate = "release_date"
        case title = "title"
        case type = "type"
    }
}

extension ListofNextMCUFilms {
    static func getDummyData() -> ListofNextMCUFilms {
        guard let url = Bundle.main.url(forResource: "MCUFilms", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(ListofNextMCUFilms.self, from: jsonData)
        else {
            return [UserDefaults.defaultNextMCUFilmResponse]
        }
        
        return response.shuffled()
    }
}

// Formatted String
extension Date {
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

typealias ListofNextMCUFilms = [NextMcuFilm]
