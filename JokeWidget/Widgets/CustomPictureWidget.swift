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
        PictureEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PictureEntry) -> Void) {
        UIImage.loadImages { imagesArray in
            completion(PictureEntry(image: imagesArray.randomElement()))
        } onError: {
#if DEBUG
print($0)
#endif
            completion(PictureEntry())
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PictureEntry>) -> Void) {
        UIImage.loadImages { (imageArray: [UIImage]) in
            if imageArray.count == 1 {
                let entries = [PictureEntry(image: imageArray.first)]
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                return
            }
            
            var entries = [PictureEntry]()
            
            for (hourOffset, image) in imageArray.enumerated() {
                let components = DateComponents(hour: hourOffset)
                let entryDate = Calendar.current.date(byAdding: components, to: .now)!
                
                let pictureEntry = PictureEntry(image: image, at: entryDate)
                entries.append(pictureEntry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } onError: {
            #if DEBUG
            print($0)
            #endif
            
            let entries = [PictureEntry()]
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
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
