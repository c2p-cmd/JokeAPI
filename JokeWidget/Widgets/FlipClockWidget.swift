//
//  FlipClockWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 28/09/23.
//

import SwiftUI
import WidgetKit

struct ClockEntry: TimelineEntry {
    let date: Date
    
    init(_ date: Date) {
        self.date = date
    }
}

struct ClockTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(.now)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> Void) {
        let entry = ClockEntry(.now)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> Void) {
        var entries = [ClockEntry]()
        let currentDate: Date = .now
        
        let minutes = DateComponents(minute: 15)
        let nextQuarter = Calendar.current.date(byAdding: minutes, to: currentDate)!
        
        for offset in 0 ..< 60 * 15 {
            let seconds = DateComponents(second: offset)
            let entryDate = Calendar.current.date(byAdding: seconds, to: currentDate)!
            entries.append(ClockEntry(entryDate))
        }
        
        let timeline = Timeline(entries: entries, policy: .after(nextQuarter))
        completion(timeline)
    }
}

struct FlipView: View {
    var text: String
    var backgroundColor: Color
    var invertedColor: Color
    var opacity: Double
    
    init(_ text: String, showing color: Color, and invertedColor: Color, with opacity: Double = 1) {
        self.text = text
        self.backgroundColor = color
        self.invertedColor = invertedColor
        self.opacity = opacity
    }
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var fontSize: CGFloat {
        if widgetFamily == .systemSmall {
            return 27
        }
        
        return 45
    }
    
    var paddingSize: CGFloat {
        if widgetFamily == .systemSmall {
            return 5
        }
        
        return 10
    }
    
    var body: some View {
        ZStack {
            ZStack {
                backgroundColor
                    .frame(height: fontSize * 1.2)
                    .clipShape(.rect(cornerRadius: 5))
                if text == ":" {
                    Text(text)
                        .font(.system(size: fontSize, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(invertedColor)
                        .padding(.bottom, paddingSize)
                        .opacity(opacity)
                        .animation(.spring, value: opacity)
                        .id(opacity)
                } else {
                    Text(text)
                        .font(.system(size: fontSize, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(invertedColor)
                }
            }
            .id(text)
            .transition(.push(from: .bottom))
            invertedColor
                .frame(height: 1, alignment: .center)
        }
    }
}

struct ClockEntryView: View {
    var entry: ClockEntry
    
    var formattedDate: String {
        let formatter = DateFormatter()
        
        if widgetFamily == .systemSmall {
            formatter.dateFormat = "EE, dd MMM"
            return formatter.string(from: entry.date)
        }
        
        formatter.dateFormat = "EEEE, dd MMMM"
        return formatter.string(from: entry.date)
    }
    
    var fontSize: CGFloat {
        if widgetFamily == .systemSmall {
            return 15
        }
            
        return 18
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: entry.date)
    }
    
    var timeFormatterCount: Int {
        if widgetFamily == .systemSmall {
            return 5
        }
        
        return 8
    }
    
    var backgroundColor: Color {
        switch colorScheme {
        case .light:
            return .black
        case .dark:
            return .white
        @unknown default:
            return .black
        }
    }
    
    var invertedColor: Color {
        switch colorScheme {
        case .light:
            return .white
        case .dark:
            return .black
        @unknown default:
            return .black
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        let seconds = Int(formattedTime[6 ..< 8]) ?? 0
        
        GeometryReader {
            let size = $0.size
            let width = size.width

            modiftyFor17 {
                ZStack {
                    Image(.bunny)
                        .resizable()
                        .scaledToFit()
                        .offset(
                            x: -width * [0.1, 0.25, 0.3, 0.4, 0.5].randomElement()!,
                            y: 50
                        )
                        .frame(height: 50)
                        .shadow(color: backgroundColor.opacity(0.75), radius: 5)
                    
                    VStack {
                        Text(formattedDate)
                            .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        
                        HStack {
                            ForEach(0 ..< timeFormatterCount, id: \.self) { index in
                                FlipView(
                                    formattedTime[index],
                                    showing: backgroundColor,
                                    and: invertedColor,
                                    with: seconds.isMultiple(of: 2) ? 1 : 0.1
                                )
                            }
                        }
                        .frame(alignment: .center)
                    }
                }
            }
        }
    }
    
    func modiftyFor17(_ content: () -> some View) -> some View {
        if #available(iOS 17, macOS 14,  *) {
            return content().containerBackground(.clear, for: .widget)
        } else {
            return content()
        }
    }
}

struct FlipClockWidget: Widget {
    let kind = "Flip Clock Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: ClockTimelineProvider()
        ) { entry in
            ClockEntryView(entry: entry)
        }
        .configurationDisplayName("Flip Clock")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOS 17, *)
#Preview(as: .systemSmall) {
    FlipClockWidget()
} timelineProvider: {
    ClockTimelineProvider()
}
