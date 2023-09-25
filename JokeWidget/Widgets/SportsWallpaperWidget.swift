//
//  SportsWallpaperWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 25/09/23.
//

import AppIntents
import SwiftUI
import WidgetKit

struct SportsWallpaperEntry: TimelineEntry {
    let date: Date = .now
    var uiImage: UIImage = UIImage(systemName: "macpro.gen3.server")!
    var sportsChoice: IntentParameter<SportsChoice>
}

@available(iOSApplicationExtension 17, *)
struct SportsWallpaperTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = SportsWallpaperEntry
    typealias Intent = SportsChoiceIntent
    
    func placeholder(in context: Context) -> SportsWallpaperEntry {
        SportsWallpaperEntry(sportsChoice: .init(title: ""))
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> SportsWallpaperEntry {
        var sportsWallpaper = SportsWallpaperEntry(sportsChoice: configuration.$sportsChoice)
        let result = await configuration.fetchImage()
        
        switch result {
        case .success(let wallpaper):
            sportsWallpaper.uiImage = wallpaper
            return sportsWallpaper
        case .failure(_):
            return sportsWallpaper
        }
    }
    
    func timeline(for configuration: Intent, in context: Context) async -> Timeline<SportsWallpaperEntry> {
        var sportsWallpaper = SportsWallpaperEntry(sportsChoice: configuration.$sportsChoice)
        let result = await configuration.fetchImage()
        
        switch result {
        case .success(let wallpaper):
            sportsWallpaper.uiImage = wallpaper
            let offset = Calendar.current.date(byAdding: .hour, value: 12, to: .now)!
            let timeline = Timeline(entries: [sportsWallpaper], policy: .after(offset))
            return timeline
        case .failure(_):
            let offset = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
            let timeline = Timeline(entries: [sportsWallpaper], policy: .after(offset))
            return timeline
        }
    }
}

@available(iOS 17, *)
struct SportsWallpaperEntryView: View {
    var entry: SportsWallpaperEntry
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(intent: SportsChoiceIntent(sportsChoice: entry.sportsChoice)) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .foregroundColor(.white)
                }
                .tint(.red.opacity(0.5))
                .frame(height: 5, alignment: .bottomTrailing)
                .buttonBorderShape(.circle)
                .buttonStyle(.borderedProminent)
            }
        }
        .containerBackground(for: .widget) {
            Image(uiImage: entry.uiImage)
                .resizable()
                .scaledToFill()
        }
    }
}

@available(iOS 17, *)
struct SportsWallpaperWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "SportsWallpaperWidget",
            provider: SportsWallpaperTimelineProvider()
        ) { entry in
            SportsWallpaperEntryView(entry: entry)
        }
        .configurationDisplayName("Sports Wallpaper")
        .description("Wallpaper for sports you like.")
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall, .systemExtraLarge])
    }
}
