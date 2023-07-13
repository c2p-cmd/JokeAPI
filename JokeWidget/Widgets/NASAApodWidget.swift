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
    var title: String = "Some title about the image"
    var showTitle = true
}

struct NASAApodTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> NASAApodEntry {
        NASAApodEntry()
    }
    
    func getSnapshot(for configuration: NASAWidgetConfigIntent, in context: Context, completion: @escaping (NASAApodEntry) -> Void) {
        fetchNASAApod(showTitle: configuration.showTitle as? Bool) { newEntry, _ in
            completion(newEntry)
        }
    }
    
    func getTimeline(for configuration: NASAWidgetConfigIntent, in context: Context, completion: @escaping (Timeline<NASAApodEntry>) -> Void) {
        fetchNASAApod(showTitle: configuration.showTitle as? Bool) { (newEntry: NASAApodEntry, didError: Bool) in
            // if success fetch new image tomorrow
            let tomorrowComponents = DateComponents(day: 1)
            let tomorrow = Calendar.current.date(byAdding: tomorrowComponents, to: newEntry.date)!
            
            // if errored retry after an hour
            let nextHourComponents = DateComponents(day: 1)
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
        .widgetURL(URL(string: "widget://nasa_apod"))
        .modifyForiOS17(.black)
    }
}

struct NASAApodWidget: Widget {
    let kind = "NASA Apod Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: NASAWidgetConfigIntent.self,
            provider: NASAApodTimelineProvider(),
            content: { entry in
                NASAApodEntryView(entry: entry)
            }
        )
        .configurationDisplayName("NASA Apod Widget")
        .description("This widget will show an image from NASA's website for today.")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
    }
}

//struct Preview: PreviewProvider {
//    static var previews: some View {
//        NASAApodEntryView(entry: NASAApodEntry(showTitle: true))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//    }
//}
