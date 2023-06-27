//
//  JokeEntry.swift
//  JokeApp
//
//  Created by kida-macbook-air on 27/06/23.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let joke: String
}

struct Provider: TimelineProvider {
    var savedJoke: String {
        return appStorage.string(forKey: "joke") ?? "No Joke"
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), joke: savedJoke)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), joke: savedJoke)
        completion(entry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SimpleEntry>) -> ()
    ) {
        getSnapshot(in: context) { entry in
            let entries: [SimpleEntry] = [entry]
            
            let reloadDate = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: entry.date
            )!
            
            let timeline = Timeline(entries: entries, policy: .after(reloadDate))
            completion(timeline)
        }
    }
}
