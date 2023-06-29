//
//  AnimalPictureWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 29/06/23.
//

import SwiftUI
import WidgetKit

struct AnimalPictureEntry: TimelineEntry {
    let date = Date.now
    var uiImage = UIImage(systemName: "pawprint.circle.fill")!
}

struct NewAnimalPictureProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> AnimalPictureEntry {
        AnimalPictureEntry()
    }
    
    @available(iOSApplicationExtension 17, *)
    func snapshot(
        for configuration: AnimalOfChoiceIntent,
        in context: Context
    ) async -> AnimalPictureEntry {
        let animalImage = await fetchAnimalImage(of: configuration.animalType)
        
        return AnimalPictureEntry(uiImage: animalImage)
    }
    
    @available(iOSApplicationExtension 17, *)
    func timeline(
        for configuration: AnimalOfChoiceIntent,
        in context: Context
    ) async -> Timeline<AnimalPictureEntry> {
        let entry = await snapshot(for: configuration, in: context)
        let nextReload = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: entry.date
        )!
        return Timeline(entries: [entry], policy: .after(nextReload))
    }
    
    typealias Entry = AnimalPictureEntry
    
    @available(iOSApplicationExtension 17, *)
    typealias Intent = AnimalOfChoiceIntent
}

struct AnimalPictureProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AnimalPictureEntry {
        AnimalPictureEntry()
    }
    
    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (AnimalPictureEntry) -> Void
    ) {
        fetchAnimalImage(of: configuration.animalType) { image in
            completion(AnimalPictureEntry(uiImage: image))
        }
    }
    
    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<AnimalPictureEntry>) -> Void
    ) {
        getSnapshot(for: configuration, in: context) { entry in
            let nextReloadDate = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: entry.date
            )!
            
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextReloadDate)
            )
            
            completion(timeline)
        }
    }
}

struct AnimalPictureEntryView: View {
    var entry: AnimalPictureEntry
    
    var imageView: some View {
        Image(uiImage: entry.uiImage)
            .resizable()
            .scaledToFit()
    }
    
    var body: some View {
        if #available(iOS 17, macOS 14, *) {
            imageView
                .containerBackground(.fill.tertiary, for: .widget)
        } else {
            imageView
        }
    }
}

struct AnimalPictureWidget: Widget {
    let kind: String = "AnimalPictureWidget"
    
    func makeConfiguration() -> some WidgetConfiguration {
        if #available(iOS 17, macOS 14, watchOS 10, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: AnimalOfChoiceIntent.self,
                provider: NewAnimalPictureProvider()
            ) { entry in
                AnimalPictureEntryView(entry: entry)
            }
        } else {
            return IntentConfiguration(
                kind: kind,
                intent: ConfigurationIntent.self,
                provider: AnimalPictureProvider()
            ) { entry in
                AnimalPictureEntryView(entry: entry)
            }
        }
    }
    
    var body: some WidgetConfiguration {
        makeConfiguration()
            .configurationDisplayName("Animal Picture Widget")
            .description("This is a widget to show you an http status with a cat or dog")
            .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
    }
}

struct AnimalPictureWidgetView_Preview: PreviewProvider {
    static var entry = AnimalPictureEntry(uiImage: UIImage(named: "102.jpg")!)
    
    static var previews: some View {
        Group {
            AnimalPictureEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            AnimalPictureEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            AnimalPictureEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
