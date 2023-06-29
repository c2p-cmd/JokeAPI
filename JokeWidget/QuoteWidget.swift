//
//  QuoteWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 28/06/23.
//

import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date = .now
    var quoteResponse = UserDefaults.defaultQuote
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry()
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (QuoteEntry) -> Void
    ) {
        completion(QuoteEntry())
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<QuoteEntry>) -> Void
    ) {
        Task {
            let result = await getRandomQuote()
            
            switch result {
            case .success(let newQuote):
                UserDefaults.saveNewQuote(newQuote)
                let entry = QuoteEntry(quoteResponse: newQuote)
                let nextReload = Calendar.current.date(
                    byAdding: .hour, value: 1, to: entry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [entry], policy: policy))
                break
            case .failure(_):
                let entry = QuoteEntry()
                let nextReload = Calendar.current.date(
                    byAdding: .hour, value: 1, to: entry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [entry], policy: policy))
                break
            }
        }
    }
}

struct QuoteWidgetEntryView: View {
    var entry: QuoteProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        VStack {
            Text("\(entry.quoteResponse.content)\n")
                .multilineTextAlignment(.center)
            HStack {
                Spacer()
                Text("-\(entry.quoteResponse.author)")
                    .multilineTextAlignment(.leading)
            }
        }.monospaced()
    }
    
    var widgetView: some View {
        VStack {
            if widgetFamily == .systemSmall {
                text().font(.caption2)
            } else {
                text().font(.caption)
            }
            if #available(iOS 17, macOS 14, *) {
                Button(intent: QuoteIntent()) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }.padding(.all, 1)
    }
    
    var body: some View {
        if #available(iOS 17, macOS 14, *) {
            widgetView
                .containerBackground(.fill.tertiary, for: .widget)
        } else {
            widgetView
        }
    }
}

struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Quote Widget")
        .description("This is a widget to feed you with a nice quote every hour.")
    }
}

//struct QuoteWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            QuoteWidgetEntryView(entry: QuoteEntry())
//                .previewContext(
//                    WidgetPreviewContext(
//                        family: .systemMedium
//                    )
//                )
//            
//            QuoteWidgetEntryView(entry: QuoteEntry())
//                .previewContext(
//                    WidgetPreviewContext(
//                        family: .systemSmall
//                    )
//                )
//        }
//    }
//}
