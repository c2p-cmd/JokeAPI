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
    var speed: Speed
    var ping: Int?
    
    init() {
        let (_, savedSpeed) = UserDefaults.savedSpeedWithPing
        self.speed = savedSpeed
        self.ping = nil
    }
    
    init(speed: Speed, ping: Int?) {
        self.speed = speed
        self.ping = ping
    }
}

struct SpeedTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpeedEntry {
        SpeedEntry(speed: Speed(value: 0.0, units: .Mbps), ping: nil)
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
            let downloadService = DownloadService.shared
            var speedEntry = SpeedEntry()
            
             // let res = await url.ping(timeout: 60)
            
//            switch res {
//            case .success(let ping):
//                UserDefaults.saveNewPing(ping)
//                speedEntry.ping = ping
//                break
//            case .failure(_):
//                speedEntry.ping = UserDefaults.savedSpeedWithPing.0
//                break
//            }
            
            downloadService.test(for: url, timeout: 60) { result in
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
    
    // old logic
    private func asyncTimeline(completion: @escaping (Timeline<SpeedEntry>) -> Void) {
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
    
    func lockScreenWidgetView(_ text: String) -> some View {
        let preview = entry.speed.value <= 0.0
        
        if preview {
            return Text("\(text)\n----")
                .contentTransition(.numericText())
                .font(.custom("DS-Digital", size: 17))
                .bold()
                .modifyForiOS17(.blue)
        }
        
        return Text("\(text)\n\(entry.speed.widgetDescription())")
            .contentTransition(.numericText())
            .font(.custom("DS-Digital", size: 17))
            .bold()
            .modifyForiOS17(.blue)
    }
    
    func homescreenWidgetView() -> some View {
        let preview = entry.speed.value <= 0.0
        
        return HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                if let ping = entry.ping {
                    if preview {
                        Text("Ping: --")
                            .font(.custom("DS-Digital", size: 21))
                            .contentTransition(.numericText())
                            .maybeInvalidatableContent()
                    } else {
                        Text("Ping: \(ping)")
                            .font(.custom("DS-Digital", size: 21))
                            .contentTransition(.numericText())
                            .maybeInvalidatableContent()
                    }
                }
                
                Text("Download Speed")
                    .font(.custom("DS-Digital", size: 16.5))
                
                if preview {
                    Text("----")
                        .font(.custom("DS-Digital", size: 30))
                        .contentTransition(.numericText())
                        .maybeInvalidatableContent()
                } else {
                    Text(entry.speed.widgetDescription())
                        .font(.custom("DS-Digital", size: 30))
                        .contentTransition(.numericText())
                        .maybeInvalidatableContent()
                }
                
                if preview {
                    Text("--")
                        .font(.custom("DS-Digital", size: 19))
                } else {
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.custom("DS-Digital", size: 19))
                }
                
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

#Preview(as: .systemMedium) {
    SpeedTestWidget()
} timeline: {
    return [
        SpeedEntry(speed: Speed(value: 0.0, units: .Mbps), ping: 34),
        SpeedEntry(speed: Speed(value: 91.8, units: .Mbps), ping: 54),
        SpeedEntry(speed: Speed(value: 126.8, units: .Mbps), ping: 304)
    ]
}

//struct SpeedWidgetEntryView_Previews: PreviewProvider {
//    static let entry = SpeedEntry(speed: Speed(value: 99.1234, units: .Mbps), ping: 200)
//
//    static var previews: some View {
//        Group {
//            SpeedWidgetEntryView(entry: entry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//
//            SpeedWidgetEntryView(entry: SpeedEntry(speed: Speed(value: 101, units: .Kbps)))
//                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//        }
//    }
//}
