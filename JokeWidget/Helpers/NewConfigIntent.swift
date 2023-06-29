//
//  NewConfigIntent.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents
import WidgetKit
import UIKit

enum AnimalChoice: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Animal Of Choice"
    
    static var caseDisplayRepresentations: [AnimalChoice : DisplayRepresentation] = [
        .cat : "Cat",
        .dog : "Dog"
    ]
    
    case cat
    case dog
}

@available(iOS 17, macOS 14, *)
struct AnimalOfChoiceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Choose fav animal"
    static var description = IntentDescription("Choose either a cat or a dog to see picture of!")
    
    @Parameter(title: "AnimalChoice", default: .cat)
    var animalType: AnimalChoice
    
    init(animalType: AnimalChoice) {
        self.animalType = animalType
    }
    
    init() {
        
    }
}

func fetchAnimalImage(
    of animalType: AnimalChoice
) async -> UIImage {
    let statusCodes: [Int] = [
        100, 101, 102, 103,
        200, 201, 202, 203, 204, 206, 207,
        300, 301, 302, 303, 304, 305, 307, 308,
        400, 401, 402, 403, 404, 405, 406, 407, 408, 409,
        410, 411, 412, 413, 414, 415, 416, 417, 418,
        421, 422, 423, 424, 425, 426, 428, 429, 431, 451,
        500, 501, 502, 503, 504, 505, 506, 507, 508, 510, 511
    ]

    var catUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.cat/\(statusCode)")!
    }

    var dogUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.dog/\(statusCode).jpg")!
    }
    
    switch animalType {
    case .cat:
        return await fetchAnimalImage(from: catUrl)
    case .dog:
        return await fetchAnimalImage(from: dogUrl)
    }
}

fileprivate func fetchAnimalImage(
    from url: URL
) async -> UIImage {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.description)
        }
        #endif
        
        guard let animalImage = UIImage(data: data) else {
            return UIImage(systemName: "wifi.exclamationmark")!
        }
        return animalImage
    } catch {
        print(error.localizedDescription)
        return UIImage(systemName: "wifi.exclamationmark")!
    }
}
