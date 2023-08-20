//
//  NextMCUFilmWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 15/08/23.
//

import SwiftUI
import WidgetKit

struct ListOfMCUFilmEntry: TimelineEntry {
    let date: Date = .now
    var nextMCFUFilmResponses: ListofNextMCUFilms = .getDummyData()
    var posterImages: [UIImage?] = [UIImage(named: "Thor"), UIImage(named: "Thor")]
}

struct MCUFilmTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ListOfMCUFilmEntry {
        .init()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ListOfMCUFilmEntry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        Task {
            let result = await getNextTwoMCUFilms()
            
            var entry = ListOfMCUFilmEntry()
            
            switch result {
            case .success(let newResponses):
                entry.nextMCFUFilmResponses = newResponses
                let urls = newResponses.map { URL(string: $0.posterUrl)! }
                entry.posterImages = await fetchImagesForMCUWidget(from: urls)
                break
            case .failure(_):
                let urls = entry.nextMCFUFilmResponses.map { URL(string: $0.posterUrl)! }
                entry.posterImages = await fetchImagesForMCUWidget(from: urls)
                break
            }
            
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ListOfMCUFilmEntry>) -> Void) {
        getSnapshot(in: context) { newEntry in
            let entries = [newEntry]
            
            let components = DateComponents(day: 1)
            let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
            
            let timeline = Timeline(entries: entries, policy: .after(reloadDate))
            completion(timeline)
        }
    }
}

struct ListOfMCUFilmEntryView: View {
    let firstFilm: NextMcuFilm
    let firstPosterImage: UIImage?
    
    let secondFilm: NextMcuFilm
    let secondPosterImage: UIImage?
    
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
    
    init(entry: ListOfMCUFilmEntry) {
        let responses = entry.nextMCFUFilmResponses
        let posterImages = entry.posterImages
        
        self.firstFilm = responses[0]
        self.firstPosterImage = posterImages[0]
        
        self.secondFilm = responses[1]
        self.secondPosterImage = posterImages[1]
    }
    
    var body: some View {
        modifyForiOS17 {
            ZStack {
                imageBG()
                    .ignoresSafeArea()
                
                if widgetFamily == .systemMedium {
                    HStack(spacing: 15) {
                        if let firstPosterImage {
                            Image(uiImage: firstPosterImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(height: height)
                        }
                        
                        VStack(spacing: 10) {
                            VStack {
                                Text("\(firstFilm.title)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                
                                Text("\(firstFilm.theReleaseDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                            }
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(.white)
                            
                            VStack {
                                Text("\(secondFilm.title)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                
                                Text("\(secondFilm.theReleaseDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                            }
                            .multilineTextAlignment(.trailing)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(.white)
                        }
                        
                        if let secondPosterImage {
                            Image(uiImage: secondPosterImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(height: height)
                        }
                    }.padding(.horizontal, 20)
                }
                
                if widgetFamily == .systemLarge {
                    HStack {
                        VStack {
                            if let firstPosterImage {
                                Image(uiImage: firstPosterImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(height: height)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(firstFilm.title)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Text(firstFilm.theReleaseDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 7.5)
                        
                        VStack {
                            if let secondPosterImage {
                                Image(uiImage: secondPosterImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(height: height)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(secondFilm.title)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Text(secondFilm.theReleaseDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 7.5)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 15)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(.white)
                }
                
                if widgetFamily == .systemSmall {
                    VStack {
                        if let image = firstPosterImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(height: height)
                        }
                        
                        Text(firstFilm.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        
                        Text(firstFilm.theReleaseDate.formatted(date: .long, time: .omitted))
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                    }
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(.white)
                    .padding()
                }
            }
        }
    }
    
    func modifyForiOS17(content: () -> some View) -> some View {
        if #available(iOSApplicationExtension 17, *) {
            return content().containerBackground(.black, for: .widget)
        }
        
        return content()
    }
    
    func imageBG() -> some View {
        Color.red
            .scaledToFill()
            .frame(width: 370)
            .opacity(0.25)
            .blur(radius: 8.0)
            .overlay {
                Color.red.opacity(0.1)
            }
    }
    
    var height: CGFloat? {
        if widgetFamily == .systemSmall {
            return 110
        }
        
        if widgetFamily == .systemMedium {
            return 150
        }
        
        if widgetFamily == .systemLarge {
            return 270
        }
        
        return nil
    }
}

struct NextMCUFilmWidget: Widget {
    let kind = "Next MCU Film Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: MCUFilmTimelineProvider()
        ) { entry in
            ListOfMCUFilmEntryView(entry: entry)
        }
        .configurationDisplayName(kind)
        .description("Simple Countdown to next Marvel Film.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct W_Preview: PreviewProvider {
    static var entry = ListOfMCUFilmEntry(nextMCFUFilmResponses: ListofNextMCUFilms.getDummyData(), posterImages: [UIImage(named: "Thor"), UIImage(named: "Marvel_Logo")])
    
    static var previews: some View {
        Group {
            ListOfMCUFilmEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ListOfMCUFilmEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ListOfMCUFilmEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
