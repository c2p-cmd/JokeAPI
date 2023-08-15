//
//  NextMCUFilmWidget.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 15/08/23.
//

import SwiftUI
import WidgetKit

struct MCUFilmEntry: TimelineEntry {
    let date: Date = .now
    var nextMCFUFilmResponse: NextMcuFilm = UserDefaults.savedNextMCUFilmResponse
    var posterImage: UIImage? = UIImage(named: "Marvel Logo")
}

struct MCUFilmTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MCUFilmEntry {
        MCUFilmEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MCUFilmEntry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
            return
        }
        
        getNextMCUFilm { result in
            switch result {
            case .success(let newResponse):
                Task {
                    var entry = MCUFilmEntry()
                    UserDefaults.saveNewNextMCUFilmResponse(newResponse)
                    entry.nextMCFUFilmResponse = newResponse
                    let (image, _) = await fetchImage(from: URL(string: newResponse.posterUrl)!)
                    entry.posterImage = image
                    completion(entry)
                }
                break
            case .failure(_):
                Task {
                    var entry = MCUFilmEntry()
                    let savedResponse = UserDefaults.savedNextMCUFilmResponse
                    entry.nextMCFUFilmResponse = savedResponse
                    let (image, didSuccess) = await fetchImage(from: URL(string: savedResponse.posterUrl)!)
                    
                    if didSuccess {
                        entry.posterImage = image
                    }
                    completion(entry)
                }
                break
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MCUFilmEntry>) -> Void) {
        getSnapshot(in: context) { newEntry in
            let entries = [newEntry]
            
            let components = DateComponents(day: 1)
            let reloadDate = Calendar.current.date(byAdding: components, to: .now)!
            
            let timeline = Timeline(entries: entries, policy: .after(reloadDate))
            completion(timeline)
        }
    }
}

struct MCUFilmEntryView: View {
    var entry: MCUFilmEntry
    
    let mcuFilm: NextMcuFilm
    
    init(entry: MCUFilmEntry) {
        self.entry = entry
        self.mcuFilm = entry.nextMCFUFilmResponse
    }
    
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    
    var body: some View {
        modifyForiOS17 {
            ZStack {
                imageBG()
                    .ignoresSafeArea()
                
                if widgetFamily == .systemLarge {
                    VStack {
                        if let image = entry.posterImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(height: height)
                        }
                        
                        Text(mcuFilm.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text(mcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(.white)
                    .padding()
                }
                
                if widgetFamily == .systemMedium {
                    HStack {
                        if let image = entry.posterImage {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(height: height)
                            }
                            .padding(.vertical, 15)
                            .padding(.leading, 20)
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text(mcuFilm.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            Text(mcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 20)
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.75)
                }
                
                if widgetFamily == .systemSmall {
                    VStack {
                        if let image = entry.posterImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(height: height)
                        }
                        
                        Text(mcuFilm.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        
                        Text(mcuFilm.theReleaseDate.formatted(date: .long, time: .omitted))
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
        Image("Marvel Logo")
            .resizable()
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
            return 300
        }
        
        return nil
    }
}

struct NextMCUFilmWidget: Widget {
    let kind = "Next MCU Film Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MCUFilmTimelineProvider()) { entry in
            MCUFilmEntryView(entry: entry)
        }
        .configurationDisplayName(kind)
        .description("Simple Countdown to next Marvel Film.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct MCUFilmEntryView_Preview: PreviewProvider {
    static var entry: MCUFilmEntry {
        var e = ListofNextMCUFilms.getDummyData().map { film in
            MCUFilmEntry(nextMCFUFilmResponse: film)
        }[3]
    
        e.posterImage = UIImage(named: "Thor")
        
        return e
    }
    
    static var previews: some View {
        MCUFilmEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        MCUFilmEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
