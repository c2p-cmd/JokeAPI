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
    var fontChoice: QuoteFont = .chalk
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
        
        completion(QuoteEntry(bgChoice: configuration.background, fontChoice: configuration.font))
    }
    
    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<QuoteEntry>) -> Void
    ) {
        Task {
            let result = await getRandomQuote()
            var entry = QuoteEntry(bgChoice: configuration.background, fontChoice: configuration.font)
            
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
    
    private var blackBoardChoice: String {
        switch self.choice {
        case .black, .unknown:
            "BLACKBOARD2"
        case .green:
            "BLACKBOARD"
        case .blackAlt:
            "black_w_chalk"
        case .greenAlt:
            "green_w_chalk"
        }
    }
    
    var body: some View {
        Image(blackBoardChoice)
            .resizable()
            .scaledToFill()
    }
}

struct QuoteWidgetEntryView: View {
    var entry: QuoteProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        var font: String
        
        switch entry.fontChoice {
        case .chalk, .unknown:
            font = "Chalkduster"
        case .easter:
            font = "EraserDust"
        }
        
        return VStack {
            Text("\(entry.quoteResponse.content)\n")
                .font(.custom(font, size: 18))
                .multilineTextAlignment(.center)
                .transition(.scale)
                .frame(alignment: .top)
                .maybeInvalidatableContent()
            
            Spacer()
            
            HStack {
                Spacer()
                Text("-\(entry.quoteResponse.author)")
                    .multilineTextAlignment(.center)
                    .font(.custom(font, size: 11.5))
                    .transition(.scale)
                    .maybeInvalidatableContent()
                
                if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                    Spacer()
                    Button(intent: QuoteIntent()) {
                        Image(systemName: "eraser.line.dashed.fill")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(alignment: .bottom)
        }
        .minimumScaleFactor(0.75)
        .shadow(radius: 10, x: 5)
        .foregroundStyle(.white)
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return text()
                .containerBackground(for: .widget) {
                    QuoteEntryView_Placeholder(entry.bgChoice)
                }
        } else {
            return text()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    ZStack {
                        if #unavailable(iOSApplicationExtension 17) {
                            QuoteEntryView_Placeholder(self.entry.bgChoice)
                                .frame(width: 370, height: 170)
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
        }
    }
    
    var body: some View {
        modifyForiOS17()
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

struct QuoteWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuoteWidgetEntryView(entry: QuoteEntry(
                quoteResponse: QuoteApiResponse("Learning is the beginning of wealth.Learning is the beginning of welath.", by: "Jim Rohn"),
                bgChoice: .green
            ))
            .previewContext(
                WidgetPreviewContext(
                    family: .systemMedium
                )
            )
        }
        .onAppear(perform: {
            let _ = UIFont.familyNames
              .flatMap { UIFont.fontNames(forFamilyName: $0) }
        })
    }
}
