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
    var speedTestDate: Date?
    var blueBG: Bool
    
    init(speed: Speed, takenAt takenDate: Date?, blue: Bool = true) {
        self.speed = speed
        self.speedTestDate = takenDate
        self.blueBG = true
    }
    
    init(blue: Bool = true) {
        (speed, speedTestDate) = UserDefaults.savedSpeedWithDate
        self.blueBG = blue
    }
}

struct SpeedTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SpeedEntry {
        SpeedEntry(speed: UserDefaults.savedSpeed, takenAt: nil, blue: false)
    }
    
    func getSnapshot(
        for configuration: SpeedTestBGIntent,
        in context: Context,
        completion: @escaping (SpeedEntry) -> Void
    ) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        completion(SpeedEntry())
    }
    
    func getTimeline(
        for configuration: SpeedTestBGIntent,
        in context: Context,
        completion: @escaping (Timeline<SpeedEntry>) -> Void
    ) {
        Task {
            let downloadService = DownloadService.shared
            var speedEntry = SpeedEntry()
            
            let result = await downloadService.testWithAnalytics(for: url, in: 60, fromWidget: context.family)
            
            switch result {
            case .success(let newSpeed):
                UserDefaults.saveNewSpeed(speed: newSpeed, at: .now)
                speedEntry.speed = newSpeed
                speedEntry.speedTestDate = .now
                break
            case .failure(_):
                (speedEntry.speed, speedEntry.speedTestDate) = UserDefaults.savedSpeedWithDate
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

struct SpeedWidget_BGImage: View {
    var blueBG = false
    
    var body: some View {
        Image(blueBG ? "SpeedTest_bluecontrast" : "Speed Widget New 1", bundle: .main)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .frame(width: 370, height: 170, alignment: .center)
            .blur(radius: 2.75)
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
        let preview = entry.speedTestDate == nil
        
        return HStack(alignment: .center) {
            if #available(iOSApplicationExtension 17, macOSApplicationExtension 14, *) {
                Button(intent: SpeedTestIntent(with: widgetFamily)) {
                    VStack(spacing: 5) {
                        Image("cellular-network")
                            .font(.custom("DS-Digital", size: 50))
                            .opacity(0.72)
                        
                        Text("Tap To\nRefresh")
                            .font(.custom("DS-Digital", size: 14.5))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(.leading, 40)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                HStack {
                    Text("⚡️ ")
                        .font(.custom("DS-Digital", size: 13.5))
                    
                    Text("Internet Speed")
                        .font(.custom("DS-Digital", size: 16.5))
                }
                
                if preview {
                    Text("----")
                        .font(.custom("DS-Digital", size: 40))
                        .contentTransition(.numericText())
                        .maybeInvalidatableContent()
                } else {
                    Text(entry.speed.widgetDescription())
                        .font(.custom("DS-Digital", size: 40))
                        .contentTransition(.numericText())
                        .maybeInvalidatableContent()
                }
                
                if let speedTestDate = entry.speedTestDate {
                    HStack {
                        Text("⏰ ")
                            .font(.custom("DS-Digital", size: 13))
                        
                        Text(speedTestDate.formatted(date: .omitted, time: .shortened))
                            .font(.custom("DS-Digital", size: 19))
                            .contentTransition(.numericText())
                            .maybeInvalidatableContent()
                    }
                } else {
                    HStack {
                        Text("⏰ ")
                            .font(.custom("DS-Digital", size: 13))
                        
                        Text("--")
                            .font(.custom("DS-Digital", size: 19))
                    }
                }
            }
        }
        .padding(.trailing, 40)
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
                SpeedWidget_BGImage(blueBG: entry.blueBG)
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
        IntentConfiguration(
            kind: kind,
            intent: SpeedTestBGIntent.self,
            provider: SpeedTimelineProvider()
        ) { entry in
            SpeedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Speed Test Widget")
        .description("This widget provides you the internet speed every hour.")
        .supportedFamilies([
            .systemMedium,
            .accessoryRectangular
        ])
    }
}

struct SpeedWidgetEntryView_Previews: PreviewProvider {
    static let entry = SpeedEntry(speed: Speed(value: 309.1234, units: .Mbps), takenAt: .distantFuture)
    
    static var previews: some View {
        Group {
            SpeedWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
