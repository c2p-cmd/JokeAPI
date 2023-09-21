//
//  NumberFunFactWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 27/07/23.
//

import SwiftUI
import WidgetKit

struct FunFactEntry: TimelineEntry {
    var date: Date = .now
    var funFact: String = UserDefaults.savedFunFact
}

struct FunFactTimelineProvider: TimelineProvider {
    typealias Entry = FunFactEntry
    
    func placeholder(in context: Context) -> Entry {
        FunFactEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        var entry = FunFactEntry()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let formattedDate = formatter.string(from: entry.date)
        
        getFactAboutDate(formattedDate: formattedDate) { newFact, _ in
            if let newFact {
                entry.funFact = newFact
            }
            
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let formattedDate = formatter.string(from: .now)
        
        getFactAboutDate(formattedDate: formattedDate) { newFact, error in
            if let newFact {
                let entries = [FunFactEntry(funFact: newFact)]
                let components = DateComponents(hour: 12)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            }
            
            if error != nil {
                let entries = [FunFactEntry()]
                let components = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            }
        }
    }
}

struct FunFactEntryView: View {
    let entry: FunFactEntry
    
    let grey: Color = Color(red: 198/256, green: 194/256, blue: 195/256)
    let textColor = Color(red: 177/256, green: 139/256, blue: 55/256)
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }()
    
    func layout() -> some View {
        return ZStack {
            Image("Fun Fact", bundle: .main)
                .resizable()
                .scaledToFill()
                .frame(width: 370, height: 170)
            
            VStack {
                Text(entry.funFact)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .top)
                
                Spacer()
                
                Text(formatter.string(from: .now))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(alignment: .bottom)
            }
            .foregroundStyle(textColor)
            .minimumScaleFactor(0.75)
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
        }
        .background(grey)
    }
    
    var body: some View {
        if #available(iOS 17, macOS 14, *) {
            layout()
                .containerBackground(grey, for: .widget)
        } else {
            layout()
        }
    }
}

struct FunFactAboutTodayWidget: Widget {
    let kind = "FunFactAboutToday"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: FunFactTimelineProvider()
        ) { entry in
            FunFactEntryView(entry: entry)
        }
        .configurationDisplayName("Fun Fact About Today!")
        .description("What happened today?")
        .supportedFamilies([.systemMedium])
    }
}

struct FunFactEntryView_Preview: PreviewProvider {
    static let entry = FunFactEntry()
    
    static var previews: some View {
        FunFactEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
