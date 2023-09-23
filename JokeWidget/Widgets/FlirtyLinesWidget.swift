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
    }
    
    var text: some View {
        HStack {
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                refreshButton
                    .rotationEffect(.degrees(180))
                    .scaleEffect(y: -1)
                Spacer()
            }
            
            Text(entry.pickup)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .shadow(radius: 1.0)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.75)
                .contentTransition(.interpolate)
                .maybeInvalidatableContent()
            
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                Spacer()
                refreshButton
            }
        }
    }
    
    @available(iOSApplicationExtension 17, macOSApplicationExtension 14, *)
    var refreshButton: some View {
        Button(intent: FlirtyLinesIntent()) {
            Image("cupid_red")
                .resizable()
                .scaledToFit()
                .frame(height: 33)
        }
        .buttonStyle(.plain)
    }
    
    var background: some View {
        Image("Flirty Coochie Coochie", bundle: .main)
            .resizable()
            .scaledToFill()
    }
    
    func modifyForiOS17() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return text
                .containerBackground(for: .widget) {
                    background
                }
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

struct FlirtyLinesEntryView_Previews: PreviewProvider {
    static let entry = FlirtyLineEntry()

    static var previews: some View {
        FlirtyLinesEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
