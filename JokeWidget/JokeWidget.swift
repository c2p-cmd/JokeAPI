//
//  JokeWidget.swift
//  JokeWidget
//
//  Created by Sharan Thakur on 04/06/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), joke: UserDefaults.savedJoke, didError: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(
            joke: UserDefaults.savedJoke,
            didError: false
        ))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getOrFetchRandomJoke(completionHandler: {
            res in
            
            switch res {
            case .success(let newJoke):
                UserDefaults.saveNewJoke(newJoke)
                let newJokeEntry = SimpleEntry(
                    joke: newJoke,
                    didError: false
                )
                let nextReload = Calendar.current.date(
                    byAdding: .hour, value: 1, to: newJokeEntry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [newJokeEntry], policy: policy))
                break
            case .failure(_):
                let newJokeEntry = SimpleEntry(
                    joke: UserDefaults.savedJoke,
                    didError: true
                )
                let nextReload = Calendar.current.date(
                    byAdding: .hour, value: 1, to: newJokeEntry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [newJokeEntry], policy: policy))
                break
            }
        })
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = .now
    var joke: String = ""
    var didError = false
}

struct JokeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        Text(entry.joke)
            .monospaced()
            .multilineTextAlignment(.center)
            .foregroundColor(entry.didError ? .black : .mint)
    }
    
    var body: some View {
        VStack {
            if widgetFamily == .systemSmall {
                text().font(.caption2)
            } else {
                text().font(.caption)
            }
        }.padding(.all, 1)
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Joke Widget")
        .description("This is a widget to feed you with joke every hour.")
    }
}

struct JokeWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            JokeWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    joke: UserDefaults.savedJoke,
                    didError: false
                )
            )
            .previewContext(
                WidgetPreviewContext(
                    family: .systemSmall
                )
            )
            
            JokeWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    joke: UserDefaults.savedJoke,
                    didError: true
                )
            )
            .previewContext(
                WidgetPreviewContext(
                    family: .systemMedium
                )
            )
        }
    }
}
