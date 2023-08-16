//
//  JokeWidget.swift
//  JokeWidget
//
//  Created by Sharan Thakur on 04/06/23.
//

import WidgetKit
import SwiftUI

struct JokeEntry: TimelineEntry {
    let date: Date = .now
    var joke: String
    var imageResource: String
    
    init(joke: String = UserDefaults.savedJoke, imageResource: String? = nil) {
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

struct JokeEntryView_Placeholder: View {
    let imageResource: String
    
    init(_ imageResource: String = "FUNNY 1") {
        self.imageResource = imageResource
    }
    
    private let gradient = LinearGradient(
        colors: [
            Color("Orange1", bundle: .main),
            Color("Orange2", bundle: .main)
        ],
        startPoint: .bottom,
        endPoint: .top
    )
    
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
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [
            Color("Orange1", bundle: .main),
            Color("Orange2", bundle: .main)
        ]), startPoint: .bottom, endPoint: .top)
    
    var entry: JokeProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func text() -> some View {
        Text(entry.joke)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .shadow(radius: 1.0)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.white)
            .padding(.all, 15)
            .transition(.push(from: .bottom))
            .maybeInvalidatableContent()
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return ZStack {
                text()
                HStack {
                    Spacer()
                    Button(intent: JokeIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
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
                    JokeEntryView_Placeholder(entry.imageResource)
                }
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Joke Widget")
        .description("This is a widget to feed you with joke every hour.")
    }
}


//#Preview("Somrhing", as: .systemMedium, widget: {
//    JokeWidget()
//}, timelineProvider: {
//    JokeProvider()
//})

//struct JokeWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        JokeWidgetEntryView(
//            entry: JokeEntry(
//                joke: """
//My employer came running to me and said, "I was looking for you all day!Where the hell have you been?"
//\nI replied, "Good employees are hard to find"
//"""
//            )
//        )
//        .previewContext(
//            WidgetPreviewContext(
//                family: .systemMedium
//            )
//        )
//    }
//}
