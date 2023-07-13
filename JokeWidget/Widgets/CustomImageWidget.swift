//
//  CustomImageWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 13/07/23.
//

import SwiftUI
import WidgetKit

struct CustomImageEntry: TimelineEntry {
    var date: Date = .now
    var uiImage: UIImage?
}

struct CustomImageProvider: TimelineProvider {
    func placeholder(in context: Context) -> CustomImageEntry {
        CustomImageEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CustomImageEntry) -> Void) {
        UIImage.loadImage { (newImage: UIImage?) in
            completion(CustomImageEntry(uiImage: newImage))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CustomImageEntry>) -> Void) {
        getSnapshot(in: context) { imageEntry in
            let timeline = Timeline(entries: [imageEntry], policy: .atEnd)
            
            completion(timeline)
        }
    }
}

struct CustomImageEntryView: View {
    var entry: CustomImageEntry
    
    func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .frame(width: .infinity, height: .infinity, alignment: .center)
    }
    
    func modifyForiOS17(_ content: some View) -> some View {
        if #available(iOS 17, macOS 14, *) {
            return content.containerBackground(.black, for: .widget)
        } else {
            return content
        }
    }
    
    var body: some View {
        ZStack {
            if let image = entry.uiImage {
                modifyForiOS17(imageView(image: image))
            } else {
                modifyForiOS17(Text("Please go into the app and choose a picture."))
            }
        }
        .ignoresSafeArea()
        .frame(width: .infinity, height: .infinity, alignment: .center)
    }
}

struct CustomImageWidget: Widget {
    let kind = "Custom Image Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CustomImageProvider()) { entry in
            CustomImageEntryView(entry: entry)
        }
        .configurationDisplayName("Custom Image Widget")
        .description("You can add your own image on this widget")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
