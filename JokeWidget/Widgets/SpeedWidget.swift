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
    var ping: Int = UserDefaults.savedSpeedWithPing.0
}

struct SpeedTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpeedEntry {
        SpeedEntry()
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (SpeedEntry) -> Void
    ) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        let speedEntry = SpeedEntry()
        completion(speedEntry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SpeedEntry>) -> Void
    ) {
        Task {
            let downloadService: DownloadService = .shared
            let result = await downloadService.testWithPing(
                for: url,
                in: 60
            )
            var speedEntry = SpeedEntry()
            
            switch result {
            case .success(let (newPing, newSpeed)):
                UserDefaults.saveNewSpeedWithPing(ping: newPing, speed: newSpeed)
                speedEntry.speed = newSpeed
                speedEntry.ping = newPing
                break
            case .failure(_):
                let (savedPing, savedSpeed) = UserDefaults.savedSpeedWithPing
                speedEntry.speed = savedSpeed
                speedEntry.ping = savedPing
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
            Image("Speed WIDGETS SCREEN2", bundle: .main)
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
                .frame(width: 370, height: 170, alignment: .center)
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
    
    func modifyForiOS17(_ view: some View) -> some View {
        if #available(iOS 17, macOS 14, *) {
            return view.containerBackground(.blue, for: .widget)
        } else {
            return view.background(.blue)
        }
    }
    
    func lockScreenWidgetView(_ text: String) -> some View {
        Text("\(text) \(entry.speed.widgetDescription())")
            .font(.custom("DS-Digital", size: 17))
            .bold()
            .modifyForiOS17()
    }
    
    func homescreenWidgetView() -> some View {
        HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text("Ping: \(entry.ping)")
                    .font(.custom("DS-Digital", size: 21))
                
                Text("Download Speed")
                    .font(.custom("DS-Digital", size: 16.5))
                
                Text(entry.speed.widgetDescription())
                    .font(.custom("DS-Digital", size: 30))
                
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.custom("DS-Digital", size: 19))
                
                if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                    Button(intent: SpeedTestIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
        .padding(.trailing, 25)
        .bold()
        .multilineTextAlignment(.trailing)
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .modifyForiOS17(.blue)
    }
    
    var body: some View {
        switch self.widgetFamily {
        case .systemMedium:
            ZStack {
                SpeedWidget_Placeholder()
                homescreenWidgetView()
            }
        case .accessoryRectangular:
            lockScreenWidgetView("Speed is")
        default:
            lockScreenWidgetView("& Speed is")
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
            // .systemSmall,
            .systemMedium,
            .accessoryRectangular
        ])
    }
}

struct SpeedWidgetEntryView_Previews: PreviewProvider {
    static let entry = SpeedEntry(speed: Speed(value: 99.1234, units: .Mbps), ping: 200)
    
    static var previews: some View {
        Group {
            SpeedWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
        .onAppear {
//            for family in UIFont.familyNames.sorted() {
//                let names = UIFont.fontNames(forFamilyName: family)
//                print("Family: \(family) Font names: \(names)")
//            }
        }
    }
}
