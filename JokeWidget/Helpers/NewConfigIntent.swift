//
//  NewConfigIntent.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 29/06/23.
//

import AppIntents
import SwiftUI
import WidgetKit
import UIKit

private let f1URLs = [
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Ferrari/3f2c8461-192b-49f3-9585-69eadab707eb.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Ferrari/682fdc1d-be85-490c-996d-e42b18109ced.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Ferrari/7b27ab54-0e52-4aed-806b-8b42dd83b957.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Ferrari/c591d80c-0083-4aee-b440-0cd13bc7b362.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Ferrari/d8fcf475-0767-4ec9-857b-8d87621af230.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Mercedes/1019784274-LAT-20230730-GP2312_140809_U1A4029.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Mercedes/GR_16x9.png",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Mercedes/M351781.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Mercedes/M362309.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Redbull/bulls-historic-one-two-finish-in-2023-bahrain.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Redbull/checo-secures-podium-finish.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Redbull/getting-up-close-and-personal.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Redbull/max-powering-through-the-rain.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/F1%20Images%20%F0%9F%8F%8E%EF%B8%8F/Redbull/sparks-fly-in-the-desert.avif"
]

private let nbaURLs = [
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Golden%20State%20Warriors/1554745780.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Golden%20State%20Warriors/1666114105.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Golden%20State%20Warriors/1666114441.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Golden%20State%20Warriors/1666630478.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Golden%20State%20Warriors/1666114249.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Houston%20Rockets/WPW_20221215_Gordon.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Houston%20Rockets/WPW_DESKTOP_LOGO_2021.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Houston%20Rockets/WPW_JALEN_2021-1.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Houston%20Rockets/houston-rockets_jalen-green_v2_wallpaper.jpg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Houston%20Rockets/houston-rockets_light-the-fuse_2_wallpaper.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Los%20Angeles%20Lakers/lakers-jack-perkins-mikan-vibes-2022023-desktop.jpeg",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/1280x1024.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/150409-wallpaper-primary-1280x1024-1.avif",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/BrookWP_ActualSize.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/MicrosoftTeams-image-1.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/MicrosoftTeams-image-6.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/Statement_Bobby_WP.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/Statement_Giannis_WP-1.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/Statement_Jevon_WP.webp",
    "https://raw.githubusercontent.com/kidastudios-in-com/WallpaperImages/master/NBA%20Images%20%F0%9F%8F%80/Milwaukee%20Bucks/wallpaper-150410-1280x1024-1.avif"
]

enum SportsChoice: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Sports To Follow")
    
    static var caseDisplayRepresentations: [SportsChoice : DisplayRepresentation] = [
        .f1 : .init(stringLiteral: "Formula 1"),
        .nba : .init(stringLiteral: "NBA")
    ]
    
    case f1
    case nba
    
    var artworkUrl: URL {
        switch self {
        case .f1:
            URL(string: f1URLs.randomElement()!)!
        case .nba:
            URL(string: nbaURLs.randomElement()!)!
        }
    }
}

@available(iOS 17, *)
struct SportsChoiceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = .init(stringLiteral: "Choose fav sport")
    
    @Parameter(title: "Sport To Follow", default: .f1)
    var sportsChoice: SportsChoice
    
    func fetchImage() async -> Result<UIImage, Error> {
        let url: URL = sportsChoice.artworkUrl
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            return .success(UIImage(data: data)?.resizedForWidget ?? UIImage(systemName: "macpro.gen3.server")!)
        } catch {
            return .failure(error)
        }
    }
    
    func perform() async throws -> some ReturnsValue<String> & ShowsSnippetView {
        let res = await fetchImage()
        switch res {
        case .success(let uiImage):
            return .result(value: "", view: Image(uiImage: uiImage))
        case .failure(_):
            break
        }
        return .result(value: "", view: Image(systemName: "car.side.fill"))
    }
}

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
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "Choose fav animal")
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
            return UIImage(named: Bool.random() ? "102_d" : "102")!
        }
        return animalImage
    } catch {
        print(error.localizedDescription)
        return UIImage(named: Bool.random() ? "102_d" : "102")!
    }
}
