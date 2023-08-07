//
//  BhagvatGitaWidget.swift
//  Ex
//
//  Created by Sharan Thakur on 07/08/23.
//

import SwiftUI
import WidgetKit

var firstResponse = BhagvatGitaResponse(chapterNo: 1, shlokNo: 1, shlok: "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||१-१||", englishTranslation: "1.1 The King Dhritarashtra asked: \"O Sanjaya! What happened on the sacred battlefield of Kurukshetra, when my people gathered against the Pandavas?\"", hindiTranslation: "।।1.1।।धृतराष्ट्र ने कहा -- हे संजय ! धर्मभूमि कुरुक्षेत्र में एकत्र हुए युद्ध के इच्छुक (युयुत्सव:) मेरे और पाण्डु के पुत्रों ने क्या किया?", englishAuthor: "Shri Purohit Swami", hindiAuthor: "Swami Tejomayananda")

struct BhagvatGitaEntry: TimelineEntry {
    var date: Date = .now
    var bhagwatGitaResponse: BhagvatGitaResponse
    var languageChoice: LanguageChoice
    
    init(
        _ bhagwatGitaResponse: BhagvatGitaResponse,
        in language: LanguageChoice = .english,
        on date: Date = .now
    ) {
        self.date = date
        self.bhagwatGitaResponse = bhagwatGitaResponse
        self.languageChoice = language == .unknown ? .english : language
    }
    
    static func randomShloka() -> BhagvatGitaEntry {
        BhagvatGitaEntry(getShlokas().first!)
    }
}

struct BhagvatGitaProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> BhagvatGitaEntry {
        BhagvatGitaEntry.randomShloka()
    }
    
    func getSnapshot(for configuration: GitaLanguageIntent, in context: Context, completion: @escaping (BhagvatGitaEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        }
        
        let entry = BhagvatGitaEntry(firstResponse, in: configuration.language)
        completion(entry)
    }
    
    func getTimeline(for configuration: GitaLanguageIntent, in context: Context, completion: @escaping (Timeline<BhagvatGitaEntry>) -> Void) {
        let shlokas = getShlokas()
        var entries: [BhagvatGitaEntry] = []
        
        for hourOffset in 0..<shlokas.count {
            let shloka = shlokas[hourOffset]
            let component = DateComponents(hour: hourOffset)
            let entryDate = Calendar.current.date(byAdding: component, to: .now)!
            let entry = BhagvatGitaEntry(shloka, in: configuration.language, on: entryDate)
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct BhagvatGitaLargeEntryView: View {
    var entry: BhagvatGitaEntry
    
    var bhagvatGitaResponse: BhagvatGitaResponse {
        entry.bhagwatGitaResponse
    }
    
    var body: some View {
        modifyForiOS17(ZStack {
            background()
            
            let brown = Color(red: 104/256, green: 63/256, blue: 17/256)
            
            VStack(spacing: 45) {
                Text(bhagvatGitaResponse.shlok)
                    .font(.custom("Devanagari Sangam MN", size: 18))
                    .animation(.easeInOut)
                
                switch entry.languageChoice {
                case .english:
                    Text(bhagvatGitaResponse.englishTranslation)
                        .font(.custom("handwriting-draft_free-version", size: 16.5))
                        .animation(.easeInOut)
                case .hindi:
                    Text(bhagvatGitaResponse.hindiTranslation.replacingOccurrences(of: " ", with: "  "))
                        .font(.custom("Devanagari Sangam MN", size: 18))
                        .animation(.easeInOut)
                case .unknown:
                    Text("")
                }
            }
            .multilineTextAlignment(.leading)
            .foregroundColor(brown)
            .minimumScaleFactor(0.75)
            .padding(.all, 25)
            
            VStack(spacing: 10) {
                Spacer()
                
                switch entry.languageChoice {
                case .english:
                    HStack {
                        Spacer()
                        Text("-\(bhagvatGitaResponse.englishAuthor)")
                            .font(.custom("handwriting-draft_free-version", size: 12.5))
                    }
                case .hindi:
                    HStack {
                        Spacer()
                        Text("-\(bhagvatGitaResponse.englishAuthor)")
                            .font(.custom("Devanagari Sangam MN", size: 12.5))
                            .animation(.easeInOut)
                    }
                case .unknown:
                    Text("")
                }
            }
            .multilineTextAlignment(.leading)
            .foregroundColor(brown)
            .minimumScaleFactor(0.75)
            .padding(.all, 27)
        })
    }
    
    private func background() -> some View {
        return Image("bhagawatGita")
            .resizable()
            .scaledToFill()
            .rotationEffect(.degrees(180))
            .frame(width: 365, height: 380)
            .ignoresSafeArea()
    }
    
    private func modifyForiOS17(_ content: some View) -> some View {
        if #available(iOS 17, *) {
            return content.containerBackground(.clear, for: .widget)
        } else {
            return content.background(background())
        }
    }
}

struct BhagvatGitaMediumEntryView: View {
    var entry: BhagvatGitaEntry
    
    var bhagvatGitaResponse: BhagvatGitaResponse {
        entry.bhagwatGitaResponse
    }
    
    var body: some View {
        modifyForiOS17(ZStack {
            background()
            
            let brown = Color(red: 104/256, green: 63/256, blue: 17/256)
            
            VStack(spacing: 18) {
                switch entry.languageChoice {
                case .english:
                    Text(bhagvatGitaResponse.englishTranslation)
                        .font(.custom("handwriting-draft_free-version", size: 18))
                        .animation(.easeInOut)
                    
                    HStack {
                        Spacer()
                        Text("-\(bhagvatGitaResponse.englishAuthor)")
                            .font(.custom("handwriting-draft_free-version", size: 12.5))
                    }
                case .hindi:
                    Text(bhagvatGitaResponse.hindiTranslation.replacingOccurrences(of: " ", with: "  "))
                        .font(.custom("Devanagari Sangam MN", size: 18))
                        .animation(.easeInOut)
                    
                    HStack {
                        Spacer()
                        Text("-\(bhagvatGitaResponse.hindiAuthor)")
                            .font(.custom("handwriting-draft_free-version", size: 12.5))
                    }
                case .unknown:
                    Text("")
                }
            }
            .foregroundColor(brown)
            .minimumScaleFactor(0.75)
            .padding(.all, 25)
        })
    }
    
    private func background() -> some View {
        return Image("bhagawatGita")
            .resizable()
            .scaledToFill()
            .frame(width: 365, height: 169)
            .ignoresSafeArea()
    }
    
    private func modifyForiOS17(_ content: some View) -> some View {
        if #available(iOS 17, *) {
            return content.invalidatableContent().containerBackground(.clear, for: .widget)
        } else {
            return content.background(background())
        }
    }
}

struct ResolverView: View {
    var entry: BhagvatGitaEntry
    
    @Environment(\.widgetFamily) private var family
    
    var body: some View {
        ZStack {
            if family == .systemLarge {
                BhagvatGitaLargeEntryView(entry: entry)
            }
            if family == .systemMedium {
                BhagvatGitaMediumEntryView(entry: entry)
            }
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
            ResolverView(entry: entry)
        }
        .configurationDisplayName("Bhagvat Gita Widget")
        .description("Everyday learn something new.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemLarge) {
    BhagvatGitaWidget()
} timeline: {
    return getShlokas().map { BhagvatGitaEntry($0, in: .hindi) }
}

#Preview(as: .systemMedium) {
    BhagvatGitaWidget()
} timeline: {
    return getShlokas().map { BhagvatGitaEntry($0, in: .english) }
}
