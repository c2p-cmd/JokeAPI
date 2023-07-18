//
//  CuteAnimalWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 18/07/23.
//

import SwiftUI
import WidgetKit

struct CuteAnimalEntry: TimelineEntry {
    var date: Date = .now
    var uiImage: UIImage = UIImage(systemName: "pawprint.circle.fill")!
    var title: String = "Cute Paw!"
    var showTitle: Bool = false
}

struct CuteAnimalProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CuteAnimalEntry {
        CuteAnimalEntry()
    }
    
    func getSnapshot(for configuration: RedditAnimalPictureIntent, in context: Context, completion: @escaping (CuteAnimalEntry) -> Void) {
        let showTitle = configuration.showTitle as? Bool ?? false
        let savedResponse = UserDefaults.savedRedditMemeResponse
        
        if let uiImage = savedResponse.uiImage {
            let entry = CuteAnimalEntry(uiImage: uiImage, title: savedResponse.title, showTitle: showTitle)
            
            completion(entry)
        } else {
            fetchImage(from: URL(string: savedResponse.url)!) { newImage, didSuccess in
                let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                
                let entry = CuteAnimalEntry(uiImage: uiImage, title: savedResponse.title, showTitle: showTitle)
                
                completion(entry)
            }
        }
    }
    
    func getTimeline(for configuration: RedditAnimalPictureIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let result = await getRedditMeme(from: allCases.randomElement()!)
            let showTitle = configuration.showTitle as? Bool ?? false
            
            switch result {
            case .success(let newResponse):
                UserDefaults.saveNewRedditResponse(newResponse)
                let components = DateComponents(day: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                if let uiImage = newResponse.uiImage {
                    let entry = CuteAnimalEntry(uiImage: uiImage, title: newResponse.title, showTitle: showTitle)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                } else {
                    fetchImage(from: URL(string: newResponse.url)!) { newImage, didSuccess in
                        let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                        let entry = CuteAnimalEntry(uiImage: uiImage, title: newResponse.title, showTitle: showTitle)
                        
                        let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                        completion(timeline)
                    }
                }
                break
            case .failure(_):
                let components = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                let savedResponse = UserDefaults.savedRedditMemeResponse
                
                if let uiImage = savedResponse.uiImage {
                    let entry = CuteAnimalEntry(uiImage: uiImage, title: savedResponse.title, showTitle: showTitle)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                } else {
                    let entry = CuteAnimalEntry(title: savedResponse.title, showTitle: showTitle)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                }
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
        ZStack(alignment: .bottom) {
            Image(uiImage: entry.uiImage)
                .resizable()
                .scaledToFill()
            
            if entry.showTitle {
                Text(entry.title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white)
                    .background(gradient)
                    .cornerRadius(5)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .multilineTextAlignment(.center)
            }
        }
        .background(.white)
        .modifyForiOS17(.black)
    }
}

struct CuteAnimalWidget: Widget {
    let kind = "Cute Animals!"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: RedditAnimalPictureIntent.self,
            provider: CuteAnimalProvider()
        ) { entry in
            CuteAnimalEntryView(entry: entry)
        }
    }
}
