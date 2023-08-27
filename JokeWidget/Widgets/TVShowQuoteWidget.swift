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
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        let entry = TVShowQuoteEntry(tvShowQuote: TVShowQuoteEntry.savedResponses().randomElement()!)
        
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
    
    func imageBG(_ width: CGFloat? = 360, _ height: CGFloat? = 169) -> some View {
        Image("tv-widgets1")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height, alignment: .center)
    }
    
    var body: some View {
        adaptToiOS17 {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(tvShowQuote.text)
                        .lineLimit(5)
                        .font(myFont(size: 15))
                        .animation(.interpolatingSpring, value: tvShowQuote.text)
                        .maybeInvalidatableContent()
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("From: \"\(tvShowQuote.show)\"")
                            .font(myFont(size: 10))
                            .animation(.interpolatingSpring, value: tvShowQuote.show)
                            .maybeInvalidatableContent()
                        
                        Spacer()
                        
                        Text("-\(tvShowQuote.character)")
                            .font(myFont(size: 10))
                            .animation(.interpolatingSpring, value: tvShowQuote.character)
                            .maybeInvalidatableContent()
                    }
                    
                    if #available(iOSApplicationExtension 17, *) {
                        HStack(alignment: .center) {
                            Spacer()
                            Button(intent: TVShowQuoteAppIntent(keepShort: true)) {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                    }
                }
                .frame(width: width * 0.75, height: height * 0.9, alignment: .top)
                .id(tvShowQuote.rawValue)
                .minimumScaleFactor(0.75)
                .padding(.vertical)
            }
        }
    }
    
    private func myFont(size: CGFloat) -> Font {
        .custom("Arial Rounded MT Bold", size: size)
    }
    
    private func adaptToiOS17(_ content: () -> some View) -> some View {
        if #available(iOSApplicationExtension 17, *) {
            return content().containerBackground(for: .widget) {
                imageBG(nil, nil)
            }
        } else {
            return content()
                .padding(.horizontal, 15)
                .background(alignment: .center) { imageBG(nil, nil) }
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

//@available(iOS 17, *)
//#Preview(as: .systemMedium) {
//    TVShowQuoteWidget()
//} timeline: {
//    return TVShowQuoteEntry.savedResponses().map { TVShowQuoteEntry(tvShowQuote: $0) }
//}
