//
//  CustomPictureWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 15/07/23.
//

import SwiftUI
import WidgetKit

struct PictureEntry: TimelineEntry {
    var date: Date
    var image: UIImage?
    
    init(image: UIImage? = nil, at date: Date = .now) {
        self.date = date
        self.image = image
    }
}

struct PictureProvider: TimelineProvider {
    func placeholder(in context: Context) -> PictureEntry {
        PictureEntry(image: UIImage(systemName: "wind.circle.fill")!)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PictureEntry) -> Void) {
        UIImage.loadImage { savedImage in
            guard savedImage == UIImage(systemName: "exclamationmark.triangle.fill")! else {
                completion(PictureEntry(image: nil))
                return
            }
            
            completion(PictureEntry(image: savedImage))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PictureEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeline)
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
