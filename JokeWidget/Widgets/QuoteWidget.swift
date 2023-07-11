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
    private let gradient = LinearGradient(colors: [
        Color("Green 1", bundle: .main),
        Color("Green 2", bundle: .main)
    ], startPoint: .bottom, endPoint: .top)
    
    var entry: QuoteProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        VStack {
            Text("\(entry.quoteResponse.content)\n")
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Text("-\(entry.quoteResponse.author) ")
                    .multilineTextAlignment(.leading)
                    .font(.system(.subheadline, design: .rounded))
            }
            
            if #available(iOS 17, macOS 14, *) {
                refreshButton()
            }
        }
        .font(.system(.body, design: .rounded))
        .bold()
        .shadow(radius: 10, y: 5)
        .foregroundStyle(.white)
    }
    
    @available(iOS 17, macOS 14, *)
    func refreshButton() -> some View {
        HStack {
            Spacer()
            Button(intent: QuoteIntent()) {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return text()
                .containerBackground(gradient, for: .widget)
        } else {
            return text()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(gradient)
        }
    }
    
    var body: some View {
        modifyForiOS17()
            .padding(.vertical, 0.1)
            .padding(.horizontal, 0.5)
    }
}

struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Quote Widget")
        .description("This is a widget to feed you with a nice quote every hour.")
    }
}

struct QuoteWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuoteWidgetEntryView(entry: QuoteEntry(
                quoteResponse: QuoteApiResponse("Learning is the beginning of welath.Learning is the beginning of welath.Learning is the beginning of welath.", by: "Jim Rohn")
            ))
            .previewContext(
                WidgetPreviewContext(
                    family: .systemMedium
                )
            )
            
            QuoteWidgetEntryView(entry: QuoteEntry(
                quoteResponse: QuoteApiResponse("मंजिल भी उसकी थी रास्ता भी उसका था,\nएक हम अकेले थे काफिला भी उसका था !", by: "Gulzar Sahab")
            ))
            .previewContext(
                WidgetPreviewContext(
                    family: .systemMedium
                )
            )
        }
    }
}
