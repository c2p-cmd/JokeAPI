//
//  BhagvatGitaWidget.swift
//  Ex
//
//  Created by Sharan Thakur on 07/08/23.
//

import SwiftUI
import WidgetKit

struct BhagvatGitaEntry: TimelineEntry {
    let date: Date
    let bhagwatGitaResponse: BhagvatGitaResponse
    let languageChoice: LanguageChoice
    
    init(
        _ bhagwatGitaResponse: BhagvatGitaResponse,
        in language: LanguageChoice = .english,
        on date: Date = .now
    ) {
        self.date = date
        self.bhagwatGitaResponse = bhagwatGitaResponse
        self.languageChoice = language == .unknown ? .english : language
    }
    
    static func randomShloka(in language: LanguageChoice = .english) -> BhagvatGitaEntry {
        let randomShloka: BhagvatGitaResponse = .getShlokas().randomElement()!
        return BhagvatGitaEntry(randomShloka, in: language)
    }
}

struct BhagvatGitaProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> BhagvatGitaEntry {
        BhagvatGitaEntry.randomShloka()
    }
    
    func getSnapshot(
        for configuration: GitaLanguageIntent,
        in context: Context,
        completion: @escaping (BhagvatGitaEntry) -> Void
    ) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        
        let entry = BhagvatGitaEntry(UserDefaults.defaultBhagvadGitaResponse, in: configuration.language)
        completion(entry)
    }
    
    func getTimeline(
        for configuration: GitaLanguageIntent,
        in context: Context,
        completion: @escaping (Timeline<BhagvatGitaEntry>) -> Void
    ) {
        getBhagvadGitaShloka { response, error in
            if error != nil {
                let timeline = buildTimeLineFromStaticData(for: configuration)
                completion(timeline)
            }
            
            if let response {
                let entry = BhagvatGitaEntry(response, in: configuration.language)
                
                let component = DateComponents(hour: 12)
                let reloadDate = Calendar.current.date(byAdding: component, to: .now)!
                
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                
                completion(timeline)
            }
        }
    }
    
    // old Logic for buildingtimeline
    func buildTimeLineFromStaticData(
        for configuration: GitaLanguageIntent
    ) -> Timeline<BhagvatGitaEntry> {
        let shlokas = BhagvatGitaResponse.getShlokas()
        var entries: [BhagvatGitaEntry] = []
        
        for hourOffset in 0..<shlokas.count {
            let shloka = shlokas[hourOffset]
            let component = DateComponents(hour: hourOffset)
            let entryDate = Calendar.current.date(byAdding: component, to: .now)!
            let entry = BhagvatGitaEntry(shloka, in: configuration.language, on: entryDate)
            
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct BhagvatGitaMediumEntryView: View {
    var entry: BhagvatGitaEntry
    
    var bhagvatGitaResponse: BhagvatGitaResponse {
        entry.bhagwatGitaResponse
    }
    
    var body: some View {
        modifyForiOS17 {
            ZStack {
                background()
                    .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    switch entry.languageChoice {
                    case .english:
                        Text(bhagvatGitaResponse.englishTranslation)
                            .font(.custom("Apple-Chancery", size: 16.5))
                            .animation(.easeInOut)
                    case .hindi:
                        Text(bhagvatGitaResponse.hindiTranslation.replacingOccurrences(of: " ", with: "  "))
                            .font(.system(size: 16.5, weight: .bold, design: .rounded))
                            .animation(.easeInOut)
                    case .unknown:
                        Text("")
                    }
                    
                    if #available(iOS 17, *) {
                        HStack {
                            if entry.languageChoice == .english {
                                Button(intent: BhagvatGitaAppIntent(shloka: entry.bhagwatGitaResponse.englishTranslation, in: .english)) {
                                    Image(systemName: "speaker.wave.2.bubble.left")
                                }
                            }
                            if entry.languageChoice == .hindi {
                                Button(intent: BhagvatGitaAppIntent(shloka: entry.bhagwatGitaResponse.hindiTranslation, in: .hindi)) {
                                    Image(systemName: "speaker.wave.2.bubble.left")
                                }
                            }
                            Spacer()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .shadow(color: Color(red: 48/256, green: 26/256, blue: 0/256), radius: 5)
                .foregroundColor(Color(red: 225/256, green: 178/256, blue: 116/256))
                .minimumScaleFactor(0.75)
                .padding(.all, 25)
            }
        }
    }
    
    private func background() -> some View {
        return Image("bhagawatGita")
            .resizable()
            .scaledToFill()
            .frame(width: 365, height: 170)
    }
    
    private func modifyForiOS17(_ content: () -> some View) -> some View {
        if #available(iOS 17, *) {
            return content().invalidatableContent().containerBackground(.clear, for: .widget)
        } else {
            return content()
        }
    }
}

struct BhagvatGitaWidget: Widget {
    let kind = "BhagvatGitaWidget"
    
    @Environment(\.widgetFamily) var family
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: GitaLanguageIntent.self,
            provider: BhagvatGitaProvider()
        ) { entry in
            BhagvatGitaMediumEntryView(entry: entry)
        }
        .configurationDisplayName("Bhagvat Gita Widget")
        .description("Everyday learn something new.")
        .supportedFamilies([.systemMedium])
    }
}

//struct BhagvatGita_Preview: PreviewProvider {
//    static var previews: some View {
//        BhagvatGitaMediumEntryView(entry: .randomShloka(in: .hindi))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
