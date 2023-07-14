//
//  CustomImageWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 13/07/23.
//

import SwiftUI
import WidgetKit

struct PexelAnimalImageEntry: TimelineEntry {
    var date: Date = .now
    var uiImage: UIImage = UIImage(systemName: "exclamationmark.triangle.fill")!
}

struct PexelAnimalImageProvider: TimelineProvider {
    func placeholder(in context: Context) -> PexelAnimalImageEntry {
        PexelAnimalImageEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PexelAnimalImageEntry) -> Void) {
        let imageUrls = UserDefaults.savedPexelsPhotoResponse.photos.map { $0.imageUrl }.randomElement()
        
        var entry = PexelAnimalImageEntry()
        
        if let randomUrl = imageUrls {
            fetchImage(from: randomUrl) { animalImage, _ in
                entry.uiImage = animalImage
                completion(entry)
            }
        } else {
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PexelAnimalImageEntry>) -> Void) {
        Task {
            let result = await getPexelPhoto(for: "animal")
            let dateComponents = DateComponents(day: 1)
            let reloadDate = Calendar.current.date(byAdding: dateComponents, to: .now)!
            var entry = PexelAnimalImageEntry()
            
            switch result {
            case .success(let newResponse):
                UserDefaults.saveNewPexelsPhotoResponse(newResponse)
                let imageUrl = newResponse.photos.map { $0.imageUrl }.randomElement()!
                
                fetchImage(from: imageUrl) { animalImage, _ in
                    entry.uiImage = animalImage
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                }
                break
            case .failure(_):
                let dateComponents = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: dateComponents, to: .now)!
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                completion(timeline)
                break
            }
        }
    }
}

struct PexelAnimalImageEntryView: View {
    var entry: PexelAnimalImageEntry
    
    func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .frame(width: .infinity, height: .infinity, alignment: .center)
            .background(.gray)
    }
    
    func modifyForiOS17(_ content: some View) -> some View {
        if #available(iOS 17, macOS 14, *) {
            return content.containerBackground(.black, for: .widget)
        } else {
            return content
        }
    }
    
    var body: some View {
        ZStack {
            modifyForiOS17(imageView(image: entry.uiImage))
        }
        .ignoresSafeArea()
        .frame(width: .infinity, height: .infinity, alignment: .center)
    }
}

struct PexelAnimalImageWidget: Widget {
    let kind = "Pexel Animal Image Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PexelAnimalImageProvider()
        ) { entry in
            PexelAnimalImageEntryView(entry: entry)
        }
        .configurationDisplayName("Custom Image Widget")
        .description("You can add your own image on this widget")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
