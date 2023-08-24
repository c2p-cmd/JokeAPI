//
//  JokeWidget.swift
//  JokeWidget
//
//  Created by Sharan Thakur on 04/06/23.
//

import WidgetKit
import SwiftUI

struct JokeEntry: TimelineEntry {
    let date: Date
    var joke: String
    var imageResource: String
    
    init(joke: String = UserDefaults.savedJoke, imageResource: String? = nil, on date: Date = .now) {
        self.date = date
        self.joke = joke
        self.imageResource = imageResource ?? "FUNNY 1"
    }
}

struct JokeProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> JokeEntry {
        JokeEntry()
    }
    
    func getSnapshot(
        for configuration: JokeCategoryChoiceIntent,
        in context: Context,
        completion: @escaping (JokeEntry) -> ()
    ) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        let selectedCategory = configuration.JokeCategory
        
        let entry = JokeEntry(imageResource: selectedCategory == "Any" ? nil : selectedCategory)
        completion(entry)
    }
    
    func getTimeline(
        for configuration: JokeCategoryChoiceIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        Task {
            let selectedCategory: String = configuration.JokeCategory ?? "Any"
            let safeMode: Bool = selectedCategory.contains("Dark") == false
            
            let res = await getRandomJoke(of: selectedCategory, type: .twopart, safeMode: safeMode)
            var entry = JokeEntry(imageResource: configuration.JokeCategory)
            
            switch res {
            case .success(let newJoke):
                UserDefaults.saveNewJoke(newJoke)
                entry.joke = newJoke
                break
            case .failure(_):
                entry.joke = UserDefaults.savedJoke
                break
            }
            
            let components = DateComponents(hour: 1)
            let nextReloadDate = Calendar.current.date(byAdding: components, to: entry.date)!
            
            let timeline = Timeline(entries: [entry], policy: .after(nextReloadDate))
            completion(timeline)
        }
    }
}

struct JokeEntryView_BackgroundImage: View {
    let imageResource: String
    
    init(_ imageResource: String = "FUNNY 1") {
        self.imageResource = imageResource
    }
    
    var body: some View {
        let configurationImage = UIImage(named: self.imageResource)
        let defaultFunnyBG = UIImage(named: "FUNNY 1")!
        
        return Image(uiImage: configurationImage ?? defaultFunnyBG)
            .resizable()
            .scaledToFill()
            .frame(width: 370, height: 170)
    }
}

struct JokeWidgetEntryView : View {
    var entry: JokeProvider.Entry
    
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
    
    var body: some View {
        modifyForiOS17 {
            ZStack(alignment: .topLeading) {
                JokeEntryView_BackgroundImage(entry.imageResource)
                    .scaledToFill()
                    .frame(alignment: .center)
                
                HStack(spacing: 20) {
                    Text(entry.joke)
                        .font(customFont)
                        .shadow(radius: 1.0)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .animation(.interpolatingSpring, value: entry.joke)
                        .id(entry.joke)
                        .frame(alignment: .topLeading)
                        .minimumScaleFactor(0.75)
                        .maybeInvalidatableContent()
                    
                    if #available(iOSApplicationExtension 17, *) {
                        Button(intent: JokeIntent()) {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.system(size: 20))
                        }
                        .frame(width: .infinity, alignment: .trailing)
                        .foregroundColor(.white)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.all, 25)
            }
        }
    }
    
    var customFont: Font {
        if entry.imageResource == "Programming" || entry.imageResource == "Dark" {
            return .custom("HiraMinProN-W3", size: 16.5)
        }
        
        return .system(size: 17, weight: .bold, design: .rounded)
    }
    
    func modifyForiOS17(_ content: () -> some View) -> some View {
        if #available(iOSApplicationExtension 17, *) {
            return content().containerBackground(.clear, for: .widget)
        } else {
            return content()
        }
    }
}

struct JokeWidget: Widget {
    let kind: String = "JokeWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: JokeCategoryChoiceIntent.self,
            provider: JokeProvider()
        ) { entry in
            JokeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Joke Widget")
        .description("This is a widget to feed you with joke every hour.")
        .supportedFamilies([.systemMedium])
    }
}

//struct JokeWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        let joke = "Who's there?\nControl Freak.\nCon....\nOK, now you say, \"Control Freak who?\""
//        
//        JokeWidgetEntryView(
//            entry: JokeEntry(joke: joke, imageResource: "Programming")
//        )
//        .previewContext(
//            WidgetPreviewContext(
//                family: .systemMedium
//            )
//        )
//    }
//}
