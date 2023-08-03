//
//  FlirtyLinesWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 24/07/23.
//

import SwiftUI
import WidgetKit

struct FlirtyLineEntry: TimelineEntry {
    let date: Date = .now
    var pickup: String = UserDefaults.savedFlirtyLine
}

struct FlirtyLinesProvider: TimelineProvider {
    func placeholder(in context: Context) -> FlirtyLineEntry {
        FlirtyLineEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FlirtyLineEntry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        getPickupLine { result in
            switch result {
            case .success(let newLine):
                UserDefaults.saveNewFlirtyLine(newLine)
                completion(FlirtyLineEntry(pickup: newLine))
                break
            case .failure(_):
                completion(FlirtyLineEntry())
                break
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlirtyLineEntry>) -> Void) {
        getPickupLine { result in
            var entry = FlirtyLineEntry()
            
            switch result {
            case .success(let newLine):
                UserDefaults.saveNewFlirtyLine(newLine)
                entry.pickup = newLine
                
                let components = DateComponents(day: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                completion(timeline)
                break
            case .failure(_):
                entry.pickup = UserDefaults.savedFlirtyLine
                let components = DateComponents(hour: 1)
                let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
                
                let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
                completion(timeline)
                break
            }
        }
    }
}

struct FlirtyLinesEntryView: View {
    var entry: FlirtyLinesProvider.Entry
    
    var body: some View {
        modifyForiOS17()
            .background(background)
    }
    
    var text: some View {
        VStack {
            Text(entry.pickup)
                .font(.custom("CarryYou-Regular", size: 30))
                .shadow(radius: 1.0)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .padding(.all, 15)
                .minimumScaleFactor(0.75)
                .transition(.slide)
                .maybeInvalidatableContent()
            
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                HStack {
                    Spacer()
                    Button(intent: FlirtyLinesIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
            }
        }
    }
    
    var background: some View {
        let bgGradient = LinearGradient(
            colors: [
                Color(red: 251 / 256, green: 87 / 256, blue: 113 / 256),
                Color(red: 227 / 256, green: 64 / 256, blue: 82 / 256),
                Color(red: 240 / 256, green: 42 / 256, blue: 63 / 256)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
        
        return Image("wp3515553")
            .offset(x: -55, y: 66)
            .rotationEffect(.degrees(-15))
            .opacity(0.25)
            .rotationEffect(.degrees(180))
            .background(bgGradient)
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return text
                .containerBackground(.pink, for: .widget)
        } else {
            return text
        }
    }
}

struct FlirtyLinesWidget: Widget {
    let kind = "Flirty Lines Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: FlirtyLinesProvider()
        ) { entry in
            FlirtyLinesEntryView(entry: entry)
        }
        .configurationDisplayName("Flirty Lines Widget")
        .description("Get a new pickup line everyday!")
        .supportedFamilies([.systemMedium])
    }
}

//struct FlirtyLinesEntryView_Previews: PreviewProvider {
//    static let entry = FlirtyLineEntry()
//
//    static var previews: some View {
//        FlirtyLinesEntryView(entry: entry)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
