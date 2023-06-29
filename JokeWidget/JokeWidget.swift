//
//  JokeWidget.swift
//  JokeWidget
//
//  Created by kida-macbook-air on 27/06/23.
//

import WidgetKit
import SwiftUI

struct JokeWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.joke)
                .font(.headline)
                .fontDesign(.monospaced)
            if #available(iOS 17, *) {
                Button(intent: JokeIntent()) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .configurationDisplayName("Joke Widget")
        .description("This is a random joke widget.")
    }
}

//#Preview(as: .systemSmall) {
//    JokeWidget()
//} timeline: {
//    SimpleEntry(date: .now, joke: appStorage.string(forKey: "joke") ?? "No Joke")
//}
