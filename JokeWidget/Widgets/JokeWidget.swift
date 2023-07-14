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

struct JokeEntryView_Placeholder: View {
    var widgetFamily: WidgetFamily
    
    var body: some View {
        if widgetFamily == .systemMedium {
            Image("md")
                .resizable()
                .scaledToFill()
        } else {
            Image("large")
                .resizable()
                .scaledToFill()
        }
    }
}

struct JokeWidgetEntryView : View {
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [
            Color("Orange1", bundle: .main),
            Color("Orange2", bundle: .main)
        ]), startPoint: .bottom, endPoint: .top)
    
    var entry: JokeProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        Text(entry.joke)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .bold()
            .padding(.vertical, 1)
            .shadow(radius: 1.0)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.white)
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return ZStack {
                text()
                HStack {
                    Spacer()
                    Button(intent: JokeIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .containerBackground(gradient, for: .widget)
        } else {
            return text()
        }
    }
    
    var body: some View {
        modifyForiOS17()
            .padding(.all, 0.15)
            .background(content: {
                JokeEntryView_Placeholder(widgetFamily: self.widgetFamily)
            })
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: JokeProvider()
        ) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Joke Widget")
        .description("This is a widget to feed you with joke every hour.")
    }
}

struct JokeWidget_Previews: PreviewProvider {
    static var previews: some View {
        JokeWidgetEntryView(
            entry: JokeEntry(
                joke: """
My employer came running to me and said, "I was looking for you all day!Where the hell have you been?"
\nI replied, "Good employees are hard to find"
"""
            )
        )
        .previewContext(
            WidgetPreviewContext(
                family: .systemMedium
            )
        )
    }
}
