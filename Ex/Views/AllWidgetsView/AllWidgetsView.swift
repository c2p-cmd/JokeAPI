//
//  AllWidgetsView.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI

struct AllWidgetsView: View {
    @StateObject private var joke = JokeViews.shared
    @StateObject private var quotes = QuoteViews.shared
    @StateObject private var speeds = SpeedTestViews.shared
    @StateObject private var flirtyLines = FlirtyLineViews.shared
    @StateObject private var nasaApod = NASApodView.shared
    @StateObject private var cuteAnimal = CuteAnimalView.shared
    private var httpAnimal = HTTPAnimalView.shared
    
    private let paddingHeight: CGFloat = 60.0
    
    var body: some View {
        List {
            // joke view
            NonStickySection(joke.views, "🤣 Joke Widgets")
                .padding(.bottom, paddingHeight)
                .tag(joke.id)
            
            // quote view
            NonStickySection(quotes.views, "💬 Quote Widgets")
                .padding(.bottom, paddingHeight)
                .tag(quotes.id)
            
            // speed test
            NonStickySection(speeds.views, "⚡️ Speed Test Widget")
                .padding(.bottom, paddingHeight)
                .tag(speeds.id)
            
            // NASA views
            NonStickySection(nasaApod.views, "🔭 NASA Apod Widget", height: 450)
                .padding(.bottom, paddingHeight)
                .tag(nasaApod.id)
            
            // flirty lines
            NonStickySection(flirtyLines.views, "😉 Flirty Lines Widget")
                .padding(.bottom, paddingHeight)
                .tag(flirtyLines.id)
            
            // cute animals
            NonStickySection(cuteAnimal.views, "🐾 Cute Animals Widget", height: 450)
                .padding(.bottom, paddingHeight)
                .tag(cuteAnimal.id)
            
            // http cat or dog
            NonStickySection(httpAnimal.views, "🥹 HTTP Cat or Dog Widget", height: 450)
                .tag(httpAnimal.id)
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

#Preview("All Widget Views", body: {
    AllWidgetsView()
})
