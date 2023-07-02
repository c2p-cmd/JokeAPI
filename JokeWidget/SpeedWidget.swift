//
//  SpeedWidget.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import WidgetKit
import SwiftUI

struct SpeedEntry: TimelineEntry {
    let date: Date = .now
    var speed: Speed = UserDefaults.savedSpeed
}

struct SpeedTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpeedEntry {
        SpeedEntry()
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (SpeedEntry) -> Void
    ) {
        completion(SpeedEntry())
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SpeedEntry>) -> Void
    ) {
        Task {
            let downloadService = DownloadService.shared
            let result = await downloadService.test(for: url, in: 60)
            var speedEntry = SpeedEntry()
            
            switch result {
            case .success(let newSpeed):
                UserDefaults.saveNewSpeed(newSpeed)
                speedEntry.speed = newSpeed
                break
            case .failure(_):
                break
            }
            
            let nextReloadDate = Calendar.current.date(byAdding: .hour, value: 1, to: speedEntry.date)!
            let timeline = Timeline(entries: [speedEntry], policy: .after(nextReloadDate))
            
            completion(timeline)
        }
    }
}

struct SpeedWidgetEntryView: View {
    var entry: SpeedTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    func lockScreenWidgetView(_ text: String) -> some View {
        HStack {
            Text("\(text) \(entry.speed.widgetDescription())")
        }
        .monospaced()
        .modifyForiOS17()
    }
    
    func homescreenWidgetView(_ text: String) -> some View {
        VStack {
            Text("\(text) \(entry.date.formatted(date: .omitted, time: .shortened))")
            Text("Speed is \(entry.speed.widgetDescription())")
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                Spacer()
                Button(intent: SpeedTestIntent()) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .monospaced()
        .modifyForiOS17()
    }
    
    var body: some View {
        switch self.widgetFamily {
        case .systemSmall:
            homescreenWidgetView("At")
                .font(.callout)
        case .accessoryRectangular:
            lockScreenWidgetView("Speed is")
                .font(.headline)
        case .accessoryInline:
            lockScreenWidgetView("& Speed is")
                .font(.headline)
        default:
            homescreenWidgetView("Hello it is")
                .font(.headline)
        }
    }
}

struct SpeedTestWidget: Widget {
    let kind = "SpeedTestWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SpeedTimelineProvider()
        ) { entry in
            SpeedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Speed Test Widget")
        .description("This widget provides you the internet speed every hour.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct SpeedWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
        
        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        
        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 99.19883, units: .Mbps)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 99.19883, units: .Mbps)))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
