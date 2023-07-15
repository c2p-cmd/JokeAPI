//
//  CustomPictureWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 15/07/23.
//

import SwiftUI
import WidgetKit

struct PictureEntry: TimelineEntry {
    let date: Date = .now
    var image: UIImage? = nil
}

struct PictureProvider: TimelineProvider {
    func placeholder(in context: Context) -> PictureEntry {
        PictureEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PictureEntry) -> Void) {
        UIImage.loadImage { savedImage in
            var entry = PictureEntry(image: savedImage)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PictureEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeLine = Timeline(entries: [entry], policy: .atEnd)
            completion(timeLine)
        }
    }
}

struct PictureEntryView: View {
    var entry: PictureEntry
    
    var widgetView: some View {
        ZStack {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text("Please go into the app and set a custom picture widget to show here.")
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.75)
            }
        }
        .ignoresSafeArea()
        .background(.gray)
    }
    
    var body: some View {
        if #available(iOS 17, macOS 14, *) {
            widgetView.containerBackground(.gray, for: .widget)
        } else {
            widgetView
        }
    }
}

struct CustomPictureWidget: Widget {
    let kind = "Custom Picture Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PictureProvider()
        ) { entry in
            PictureEntryView(entry: entry)
        }
        .configurationDisplayName("Custom Picture Widget")
        .description("This is widget in which you can set a custom image of your choice.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
