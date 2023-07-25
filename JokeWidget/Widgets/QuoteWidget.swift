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
    var quoteResponse = UserDefaults.savedQuote
    var bgChoice: QuoteBackground = .black
}

struct QuoteProvider: IntentTimelineProvider {
    typealias Intent = QuoteBGIntent
    
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry()
    }
    
    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (QuoteEntry) -> Void
    ) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        completion(QuoteEntry(quoteResponse: UserDefaults.savedQuote, bgChoice: configuration.background))
    }
    
    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<QuoteEntry>) -> Void
    ) {
        Task {
            let result = await getRandomQuote()
            var entry = QuoteEntry(bgChoice: configuration.background)
            
            switch result {
            case .success(let newQuote):
                UserDefaults.saveNewQuote(newQuote)
                entry.quoteResponse = newQuote
                let components = DateComponents(day: 1)
                let nextReload = Calendar.current.date(
                    byAdding: components, to: entry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [entry], policy: policy))
                break
            case .failure(_):
                let components = DateComponents(hour: 1)
                let nextReload = Calendar.current.date(
                    byAdding: components, to: entry.date
                )!
                let policy: TimelineReloadPolicy = .after(nextReload)
                completion(Timeline(entries: [entry], policy: policy))
                break
            }
        }
    }
}

struct QuoteEntryView_Placeholder: View {
    var choice: QuoteBackground
    
    init(_ choice: QuoteBackground) {
        self.choice = choice
    }
    
    private func blackBoardChoice() -> String {
        switch self.choice {
        case .black:
            return "BLACKBOARD2"
        case .green, .unknown:
            return "BLACKBOARD"
        }
    }
    
    var body: some View {
        Image(blackBoardChoice())
            .resizable()
            .scaledToFill()
            .frame(width: 370, height: 170)
    }
}

struct QuoteWidgetEntryView: View {
    private let gradient = LinearGradient(colors: [
        Color("BlackBoard1", bundle: .main),
        Color("BlackBoard2", bundle: .main)
    ], startPoint: .bottom, endPoint: .top)
    
    var entry: QuoteProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        VStack {
            Text("\(entry.quoteResponse.content)\n")
                .font(.custom("Chalkduster", size: 18))
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Text("-\(entry.quoteResponse.author) ")
                    .multilineTextAlignment(.trailing)
                    .font(.custom("Chalkduster", size: 11.5))
                if #available(iOS 17, macOS 14, *) {
                    Spacer()
                    refreshButton
                }
            }
        }
        .padding(.all, 15)
        .minimumScaleFactor(0.75)
        .shadow(radius: 10, x: 5)
        .foregroundStyle(.white)
    }
    
    @available(iOS 17, macOS 14, *)
    var refreshButton: some View {
        Button(intent: QuoteIntent()) {
            Image(systemName: "arrow.counterclockwise")
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return text()
                .containerBackground(gradient, for: .widget)
        } else {
            return text()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var body: some View {
        modifyForiOS17()
            .background {
                ZStack {
                    gradient
                    QuoteEntryView_Placeholder(self.entry.bgChoice)
                }
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
    }
}

struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: QuoteBGIntent.self,
            provider: QuoteProvider()
        ) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Quote Widget")
        .description("This is a widget to feed you with a nice quote every day.")
    }
}

//struct QuoteWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            QuoteWidgetEntryView(entry: QuoteEntry(
//                quoteResponse: QuoteApiResponse("Learning is the beginning of wealth.Learning is the beginning of welath.", by: "Jim Rohn")
//            ))
//            .previewContext(
//                WidgetPreviewContext(
//                    family: .systemMedium
//                )
//            )
//            
//            QuoteWidgetEntryView(entry: QuoteEntry(
//                quoteResponse: QuoteApiResponse("मंजिल भी उसकी थी रास्ता भी उसका था,\nएक हम अकेले थे काफिला भी उसका था !", by: "Gulzar Sahab")
//            ))
//            .previewContext(
//                WidgetPreviewContext(
//                    family: .systemMedium
//                )
//            )
//        }
//    }
//}
