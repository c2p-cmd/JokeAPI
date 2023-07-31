//
//  AllWidgetsView.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI

struct AllWidgetsView: View {
    @ObservedObject private var joke = JokeViews.shared
    @ObservedObject private var quotes = QuoteViews.shared
    @ObservedObject private var speeds = SpeedTestViews.shared
    @ObservedObject private var flirtyLines = FlirtyLineViews.shared
    @ObservedObject private var nasaApod = NASApodView.shared
    
    var body: some View {
        List {
            // joke view
            NonStickySection(joke.views(), "🤣 Joke Widgets")
            .tag("Joke Widgets")
            
            // quote view
            NonStickySection(quotes.views(), "💬 Quote Widgets")
            .tag("Quote Widgets")
            
            // speed test
            NonStickySection(speeds.views(), "⚡️ Speed Test Widget")
            .tag("Speed Test Widget")
            
            // NASA views
            NonStickySection(nasaApod.views(), "🔭 NASA Apod Widget", height: 450)
            .tag("NASA Apod Widget")
            
            // flirty lines
            NonStickySection(flirtyLines.views(), "😉 Flirty Lines Widget")
            .tag("Flirty Lines Widget")
        }
        .scrollIndicators(.automatic)
        .headerProminence(.standard)
        .listSectionSeparator(.hidden)
        .font(.system(.title, design: .rounded, weight: .heavy))
        .foregroundStyle(.primary)
        .listStyle(.plain)
    }
}

struct NonStickySection<V: View>: View {
    var categoryViews: [V]
    var textView: String
    var height: CGFloat? // 450 for large widget
    
    init(_ categoryViews: [V], _ textView: String) {
        self.categoryViews = categoryViews
        self.textView = textView
    }
    
    init(_ categoryViews: [V], _ textView: String, height: CGFloat) {
        self.categoryViews = categoryViews
        self.textView = textView
        self.height = height
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(self.textView)
                Spacer()
            }
            
            if self.categoryViews.count == 1 {
                self.categoryViews.first!
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .center, spacing: 20) {
                        let indices: Range<Int> = self.categoryViews.indices
                        
                        ForEach(indices, id: \.self) {
                            self.categoryViews[$0]
                        }
                    }
                }
            }
        }
        .frame(height: self.height)
    }
}

struct AllWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AllWidgetsView()
    }
}
