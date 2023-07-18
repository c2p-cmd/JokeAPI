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
        let speedEntry = SpeedEntry(speed: UserDefaults.savedSpeed)
        completion(speedEntry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SpeedEntry>) -> Void
    ) {
        Task {
            let downloadService: DownloadService = .shared
            let result = await downloadService.test(for: url, in: 60)
            var speedEntry = SpeedEntry()
            
            switch result {
            case .success(let newSpeed):
                UserDefaults.saveNewSpeed(newSpeed)
                speedEntry.speed = newSpeed
                break
            case .failure(_):
                speedEntry.speed = UserDefaults.savedSpeed
                break
            }
            
            let components = DateComponents(hour: 1)
            let nextReloadDate = Calendar.current.date(
                byAdding: components, to: speedEntry.date
            )!
            let policy: TimelineReloadPolicy = .after(nextReloadDate)
            let timeline = Timeline(entries: [speedEntry], policy: policy)
            
            completion(timeline)
        }
    }
}

struct SpeedWidget_Placeholder: View {
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    var body: some View {
        if widgetFamily == .systemMedium {
            Image("mdb", bundle: .main)
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        } else {
            Image("xl lg sm", bundle: .main)
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
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
        VStack(spacing: 21) {
            VStack {
                Text("\(text) \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 18.5, weight: .bold, design: .monospaced))
                Text("Speed is \(entry.speed.widgetDescription())")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
            }
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                Button(intent: SpeedTestIntent()) {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
        .buttonStyle(.plain)
        .monospaced(true)
        .foregroundStyle(.white)
        .modifyForiOS17(.blue)
    }
    
    var body: some View {
        switch self.widgetFamily {
        case .systemSmall:
            SpeedWidget_Placeholder()
                .overlay {
                    homescreenWidgetView("At")
                        .font(.callout)
                }
        case .systemMedium:
            SpeedWidget_Placeholder()
                .overlay {
                    homescreenWidgetView("Hello it is")
                        .font(.headline)
                }
        case .accessoryRectangular:
            lockScreenWidgetView("Speed is")
                .font(.headline)
        case .accessoryInline:
            lockScreenWidgetView("& Speed is")
                .font(.headline)
        default:
            SpeedWidget_Placeholder()
                .overlay {
                    homescreenWidgetView("Hello it is")
                        .font(.headline)
                }
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

//struct SpeedWidgetEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 99.19883, units: .Mbps)))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//        
//        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 99.19883, units: .Mbps)))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//        
//        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
//            .previewContext(WidgetPreviewContext(family: .accessoryInline))
//        
//        SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//    }
//}
