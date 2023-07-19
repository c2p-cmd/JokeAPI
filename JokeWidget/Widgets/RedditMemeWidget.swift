//
//  RedditMemeWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 19/07/23.
//

import SwiftUI
import WidgetKit

struct MemeEntry: TimelineEntry {
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

struct MemeProvider: TimelineProvider {
    typealias Entry = MemeEntry
    
    func placeholder(in context: Context) -> Entry {
        MemeEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        let savedResponse = UserDefaults.savedRedditMemeResponse
        
        if let uiImage = savedResponse.uiImage {
            let entry = MemeEntry(uiImage: uiImage, title: savedResponse.title)
            
            completion(entry)
        } else {
            fetchImage(from: URL(string: savedResponse.url)!) { newImage, didSuccess in
                let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                
                let entry = MemeEntry(uiImage: uiImage, title: savedResponse.title)
                
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let result = await getRedditMeme(from: allMemeSubreddits.randomElement()!.string)
            
            switch result {
            case .success(let newResponse):
                UserDefaults.saveNewRedditMemeResponse(newResponse)
                let components = DateComponents(day: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                if let uiImage = newResponse.uiImage {
                    let entry = MemeEntry(uiImage: uiImage, title: newResponse.title)
                    
                    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                    completion(timeline)
                } else {
                    fetchImage(from: URL(string: newResponse.url)!) { newImage, didSuccess in
                        let uiImage = didSuccess ? newImage : UIImage(systemName: "pawprint.circle.fill")!
                        let entry = MemeEntry(uiImage: uiImage, title: newResponse.title)
                        
                        let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                        completion(timeline)
                    }
                }
                break
            case .failure(_):
                let components = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                let savedResponse = UserDefaults.savedRedditMemeResponse
                
                let entry = MemeEntry(uiImage: savedResponse.uiImage, title: savedResponse.title)
                
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                completion(timeline)
                break
            }
        }
    }
}

struct MemeEntryView: View {
    let gradient = LinearGradient(colors: [
        .orange.opacity(0.9),
        .orange.opacity(0.75),
        .orange.opacity(0.1)
    ], startPoint: .bottom, endPoint: .top)
    
    var entry: MemeEntry
    
    var body: some View {
        VStack {
            VStack {
                Image(uiImage: entry.uiImage)
                    .resizable()
                    .scaledToFill()
                    .padding(.horizontal, 10)
                    .modifyForiOS17(.clear)
                
                Text(entry.title)
                    .font(.system(
                        size: 15,
                        weight: .semibold,
                        design: .rounded))
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.75)
            }.padding()
        }
        .background {
            Image("Iarge")
                .resizable()
                .scaledToFill()
        }
    }
}

struct MemeWidget: Widget {
    let kind = "Reddit Memes!"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: MemeProvider()
        ) { entry in
            MemeEntryView(entry: entry)
        }
        .configurationDisplayName("Reddit Meme Widget")
        .description("Be fed with a nice meme everyday!")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

struct MemeWidget_Previews: PreviewProvider {
    static let entry = MemeEntry(
        uiImage: UIImage(named: "5vk4ob6hnrcb1"),
        title: "Hoping for an Extraordinary Future for My Newborn"
    )
    
    static var previews: some View {
        MemeEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
