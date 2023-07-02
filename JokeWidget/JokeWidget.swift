//
//  JokeWidget.swift
//  JokeWidget
//
//  Created by Sharan Thakur on 04/06/23.
//

import WidgetKit
import SwiftUI

struct JokeEntry: TimelineEntry {
    let date: Date = .now
    var joke: String = ""
    var didError = false
}

struct JokeProvider: TimelineProvider {
    func placeholder(in context: Context) -> JokeEntry {
        JokeEntry(joke: UserDefaults.savedJoke, didError: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (JokeEntry) -> ()) {
        completion(JokeEntry(
            joke: UserDefaults.savedJoke,
            didError: false
        ))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let res = await getRandomJoke(of: [], safeMode: true)
            
            switch res {
            case .success(let newJoke):
                UserDefaults.saveNewJoke(newJoke)
                let newJokeEntry = JokeEntry(
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
                let newJokeEntry = JokeEntry(
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
        }
    }
}

struct JokeWidgetEntryView : View {
    var entry: JokeProvider.Entry
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
            if #available(iOS 17, macOS 14, *) {
                Button(intent: JokeIntent()) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
        .padding(.all, 1)
        .modifyForiOS17()
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JokeProvider()) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Joke Widget")
        .description("This is a widget to feed you with joke every hour.")
    }
}

struct JokeWidget_Previews: PreviewProvider {
    static var previews: some View {
        JokeWidgetEntryView(
            entry: JokeEntry(
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
            entry: JokeEntry(
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
