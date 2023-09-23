//
//  NASAApodWidget.swift
//  Ex
//
//  Created by Sharan Thakur on 11/07/23.
//

import SwiftUI
import WidgetKit

struct NASAApodEntry: TimelineEntry {
    let date: Date = .now
    var uiImage: UIImage = UIImage(named: "AuroraSnow")!
}

struct NASAApodTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NASAApodEntry {
        NASAApodEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NASAApodEntry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        fetchNASAApod(showTitle: false) { newEntry, _ in
            completion(newEntry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NASAApodEntry>) -> Void) {
        fetchNASAApod(showTitle: false) { (newEntry: NASAApodEntry, didError: Bool) in
            // if success fetch new image after 12 hours
            let halfDayComponent = DateComponents(hour: 12)
            let tomorrow = Calendar.current.date(byAdding: halfDayComponent, to: newEntry.date)!
            
            // if errored retry after an hour
            let nextHourComponents = DateComponents(minute: 15)
            let nextHour = Calendar.current.date(byAdding: nextHourComponents, to: newEntry.date)!
            
            let nextReloadDate = didError ? tomorrow : nextHour
            
            let timeline = Timeline(entries: [newEntry], policy: .after(nextReloadDate))
            completion(timeline)
        }
    }
}

struct NASAApodEntryView: View {
    let gradient = LinearGradient(colors: [
        .black.opacity(0.9),
        .black.opacity(0.75),
        .black.opacity(0.1)
    ], startPoint: .bottom, endPoint: .top)
    
    var entry: NASAApodEntry
    
    var body: some View {
        modifyForiOS17 {
            ZStack {
                if #unavailable(iOSApplicationExtension 17) {
                    Image(uiImage: entry.uiImage)
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }
    
    func modifyForiOS17(content: () -> some View) -> some View {
        if #available(iOS 17, *) {
            return content().containerBackground(for: .widget) {
                Image(uiImage: entry.uiImage)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            return content()
        }
    }
}

struct NASAApodWidget: Widget {
    let kind = "NASA Apod Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: NASAApodTimelineProvider(),
            content: { entry in
                NASAApodEntryView(entry: entry)
            }
        )
        .configurationDisplayName("NASA Apod Widget")
        .description("This widget will show an image from NASA's website for today.")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}
