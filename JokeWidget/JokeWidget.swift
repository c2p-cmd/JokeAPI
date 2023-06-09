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
        SimpleEntry(date: Date(), didError: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        getOrFetchRandomJoke(completionHandler: {
            res in
            
            switch res {
            case .success(let newJoke):
                let newJokeEntry = SimpleEntry(
                    joke: newJoke,
                    didError: false
                )
                completion(newJokeEntry)
                break
            case .failure(_):
                completion(
                    SimpleEntry(
                        didError: true
                    )
                )
                break
            }
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) {
            entry in
            
            let nextReload = Calendar.current.date(
                byAdding: .hour, value: 1, to: entry.date
            )!
            let policy: TimelineReloadPolicy = .after(nextReload)
            
            completion(Timeline(entries: [entry], policy: policy))
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    var joke: String = ""
    var didError = false
}

struct JokeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.didError {
            Text(UserDefaults.savedJoke)
                .font(.caption)
                .monospaced()
                .multilineTextAlignment(.center)
                .foregroundColor(.mint)
        } else {
            Text(entry.joke)
                .font(.caption)
                .monospaced()
                .multilineTextAlignment(.center)
        }
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
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
                    didError: true
                )
            )
            .previewContext(
                WidgetPreviewContext(
                    family: .systemMedium
                )
            )
            
            JokeWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    didError: true
                )
            )
            .previewContext(
                WidgetPreviewContext(
                    family: .systemLarge
                )
            )
        }
    }
}
