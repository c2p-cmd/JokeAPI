//
//  CuteAnimalWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 18/07/23.
//

import SwiftUI
import WidgetKit

struct CuteAnimalEntry: TimelineEntry {
    var date: Date
    var uiImage: UIImage
    var title: String
    
    init(date: Date = .now, uiImage: UIImage?, title: String = "Cute Paw!") {
        self.date = date
        self.uiImage = uiImage ?? UIImage(systemName: "pawprint.circle.fill")!
        self.title = title
    }
    
    init(date: Date = .now, uiImage: UIImage = UIImage(systemName: "pawprint.circle.fill")!, title: String = "Cute Paw!") {
        self.date = date
        self.uiImage = uiImage
        self.title = title
    }
}

struct CuteAnimalProvider: TimelineProvider {
    func placeholder(in context: Context) -> CuteAnimalEntry {
        CuteAnimalEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CuteAnimalEntry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        let savedResponse = UserDefaults.savedRedditMemeResponse
        
        if let uiImage = savedResponse.uiImage {
            let entry = CuteAnimalEntry(uiImage: uiImage, title: savedResponse.title)
            
            completion(entry)
        } else {
            fetchImage(from: URL(string: savedResponse.url)!) { newImage, didSuccess in
                let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                
                let entry = CuteAnimalEntry(uiImage: uiImage, title: savedResponse.title)
                
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CuteAnimalEntry>) -> Void) {
        Task {
            let result = await getRedditMeme(from: allCases.randomElement()!)
            
            switch result {
            case .success(let newResponse):
                UserDefaults.saveNewRedditResponse(newResponse)
                let components = DateComponents(day: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                if let uiImage = newResponse.uiImage {
                    let entry = CuteAnimalEntry(uiImage: uiImage, title: newResponse.title)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                } else {
                    fetchImage(from: URL(string: newResponse.url)!) { newImage, didSuccess in
                        let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                        let entry = CuteAnimalEntry(uiImage: uiImage, title: newResponse.title)
                        
                        let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                        completion(timeline)
                    }
                }
                break
            case .failure(_):
                let components = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                let savedResponse = UserDefaults.savedRedditMemeResponse
                
                let entry = CuteAnimalEntry(uiImage: savedResponse.uiImage, title: savedResponse.title)
                
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                completion(timeline)
                break
            }
        }
    }
}

struct CuteAnimalEntryView: View {
    let gradient = LinearGradient(colors: [
        .black.opacity(0.9),
        .black.opacity(0.75),
        .black.opacity(0.1)
    ], startPoint: .bottom, endPoint: .top)
    
    var entry: CuteAnimalEntry
    
    var body: some View {
        Image(uiImage: entry.uiImage)
            .resizable()
            .scaledToFill()
            .modifyForiOS17(gradient)
    }
}

struct CuteAnimalWidget: Widget {
    let kind = "Cute Animals!"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CuteAnimalProvider()
        ) { entry in
            CuteAnimalEntryView(entry: entry)
        }
        .configurationDisplayName("Cute Animal Widget")
        .description("Be fed with a cute animal widget every day!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
