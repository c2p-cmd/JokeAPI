//
//  MemeGeneratorModels.swift
//  Ex
//
//  Created by Sharan Thakur on 19/07/23.
//

import Foundation

// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - MemeTemplate
struct MemeTemplate: Codable, Hashable {
    let id: String
    let name: String
    let lines: Int
    let overlays: Int
    let example: Example
    let source: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case lines = "lines"
        case overlays = "overlays"
        case example = "example"
        case source = "source"
    }
    
    static var defaultMemeTemplate: MemeTemplate {
        MemeTemplate(
            id: "ds",
            name: "Daily Struggle",
            lines: 3,
            overlays: 1,
            example: Example(
                text: [
                    "The dress is black and blue.",
                    "The dress is gold and white."
                ],
                url: "https://api.memegen.link/images/ds/The_dress_is_black_and_blue./The_dress_is_gold_and_white..png"
            ),
            source: "https://knowyourmeme.com/memes/daily-struggle"
        )
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Example
struct Example: Codable, Hashable {
    let text: [String]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
        case url = "url"
    }
}

typealias MemeTemplates = [MemeTemplate]
