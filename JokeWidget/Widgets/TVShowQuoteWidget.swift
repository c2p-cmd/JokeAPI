//
//  TVShowQuoteWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 11/08/23.
//

import SwiftUI
import WidgetKit

struct TVShowQuoteEntry: TimelineEntry {
    let tvShowQuote: TVShowQuoteResponse
    let date: Date
    
    init(tvShowQuote: TVShowQuoteResponse, at date: Date = .now) {
        self.tvShowQuote = tvShowQuote
        self.date = date
    }
    
    static func savedResponses() -> TVShowQuoteResponses {
        UserDefaults.savedTVShowQuotes
    }
}

struct TVShowQuoteProvider: IntentTimelineProvider {
    typealias Entry = TVShowQuoteEntry
    typealias Intent = TVShowIntentIntent
    
    func placeholder(in context: Context) -> Entry {
        let response = TVShowQuoteEntry.savedResponses().randomElement()!
        return TVShowQuoteEntry(tvShowQuote: response)
    }
    
    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> Void
    ) {
        let entry = placeholder(in: context)
        
        completion(entry)
    }
    
    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let tvShowChosen = configuration.tvShowChoice ?? TVShowQuoteResponses.allShows.randomElement()!
        
        let quoteCount = 3
        
        getTVShowQuote(
            from: tvShowChosen,
            count: quoteCount,
            keepShort: true
        ) { responses, _ in
            let timeline = buildTimeline(for: responses)
            completion(timeline)
        }
    }
    
    private func buildTimeline(
        for responses: TVShowQuoteResponses
    ) -> Timeline<Entry> {
        var entries: [TVShowQuoteEntry] = []
        
        for hourOffset in 0..<responses.count {
            let response = responses[hourOffset]
            let components = DateComponents(hour: hourOffset)
            
            let entryDate = Calendar.current.date(byAdding: components, to: .now)!
            let entry = TVShowQuoteEntry(tvShowQuote: response, at: entryDate)
            
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct TVShowQuoteEntryView: View {
    var entry: TVShowQuoteEntry
    
    var tvShowQuote: TVShowQuoteResponse {
        entry.tvShowQuote
    }
    
    var body: some View {
        adaptToiOS17(ZStack {
            Image("TV_Quote_BG")
                .resizable()
                .scaledToFill()
                .frame(width: 369, height: 380)
            
            
            VStack(spacing: 10) {
                Text(tvShowQuote.text)
                    .lineLimit(5)
                    .font(myFont(size: 15))
                    .animation(.interpolatingSpring, value: tvShowQuote.text)
                    .maybeInvalidatableContent()
                
                HStack {
                    Text("From: \"\(tvShowQuote.show)\"")
                        .font(myFont(size: 12))
                        .animation(.interpolatingSpring, value: tvShowQuote.show)
                        .maybeInvalidatableContent()
                    
                    Spacer()
                    
                    Text("-\(tvShowQuote.character)")
                        .font(myFont(size: 12))
                        .animation(.interpolatingSpring, value: tvShowQuote.character)
                        .maybeInvalidatableContent()
                    
                    if #available(iOSApplicationExtension 17, *) {
                        Button(intent: TVShowQuoteAppIntent(keepShort: true)) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 5)
            }
            .id(tvShowQuote.rawValue)
            .minimumScaleFactor(0.75)
            .padding(.all, 25)
        })
    }
    
    private func myFont(size: CGFloat) -> Font {
        .custom("Arial Rounded MT Bold", size: size)
    }
    
    private func adaptToiOS17(_ content: some View) -> some View {
        if #available(iOSApplicationExtension 17, *) {
            return content.containerBackground(.clear, for: .widget)
        } else {
            return content
        }
    }
}

struct TVShowQuoteWidget: Widget {
    let kind = "TV Show Quote Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: TVShowIntentIntent.self,
            provider: TVShowQuoteProvider()
        ) { entry in
            TVShowQuoteEntryView(entry: entry)
        }
        .configurationDisplayName("TV Show Quotes")
        .description("Random Quotes from your favourite tv shows")
        .supportedFamilies([.systemMedium])
    }
}

//struct Preview: PreviewProvider {
//    static var previews: some View {
//        TVShowQuoteEntryView(
//            entry: TVShowQuoteEntry(tvShowQuote: TVShowQuoteEntry.savedResponses().randomElement()!)
//        ).previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
