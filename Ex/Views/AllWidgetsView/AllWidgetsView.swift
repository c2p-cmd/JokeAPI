//
//  AllWidgetsView.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI

struct AllWidgetsView: View {
    @State var showBottomSheet = false
    
    @StateObject private var joke = JokeViews.shared
    @StateObject private var quotes = QuoteViews.shared
    @StateObject private var speeds = SpeedTestViews.shared
    @StateObject private var flirtyLines = FlirtyLineViews.shared
    @StateObject private var nasaApod = NASApodView.shared
    @StateObject private var cuteAnimal = CuteAnimalView.shared
    @StateObject private var funFactAboutToday = FunFactAboutTodayView.shared
    
    private var httpAnimal = HTTPAnimalView.shared
    
    var body: some View {
        List {
            // joke view
            NonStickySection(
                title: "🤣 Joke Widgets",
                showing: joke.views,
                showBottomSheet: $showBottomSheet
            ).tag(joke.id)
            
            // quote view
            NonStickySection(
                title: "💬 Quote Widgets",
                showing: quotes.views,
                showBottomSheet: $showBottomSheet
            ).tag(quotes.id)
            
            // speed test
            NonStickySection(
                title: "⚡️ Speed Test Widget",
                showing: speeds.views,
                showBottomSheet: $showBottomSheet
            ).tag(speeds.id)
            
            // NASA views
            NonStickySection(
                title: "🔭 NASA Apod Widget",
                showing: nasaApod.views,
                height: 450,
                showBottomSheet: $showBottomSheet
            ).tag(nasaApod.id)
            
            // flirty lines
            NonStickySection(
                title: "😉 Flirty Lines Widget",
                showing: flirtyLines.views,
                showBottomSheet: $showBottomSheet
            ).tag(flirtyLines.id)
            
            // cute animals
            NonStickySection(
                title: "🐾 Cute Animals Widget",
                showing: cuteAnimal.views,
                height: 450,
                showBottomSheet: $showBottomSheet
            ).tag(cuteAnimal.id)
            
            // fun fact about today
            NonStickySection(
                title: "🗓️ Fun Fact About Today Widget",
                showing: funFactAboutToday.views,
                showBottomSheet: $showBottomSheet
            ).tag(funFactAboutToday.id)
            
            // http cat or dog
            NonStickySection(
                title: "🥹 HTTP Cat or Dog Widget",
                showing: httpAnimal.views,
                height: 450,
                showBottomSheet: $showBottomSheet
            ).tag(httpAnimal.id)
        }
        .scrollIndicators(.automatic)
        .headerProminence(.standard)
        .listSectionSeparator(.hidden)
        .font(.system(.title, design: .rounded, weight: .heavy))
        .foregroundStyle(.primary)
        .listStyle(.plain)
        .sheet(isPresented: $showBottomSheet) {
            BottomSheet {
                withAnimation {
                    showBottomSheet = false
                }
            }
        }
    }
}

struct BottomSheet: View {
    var action: () -> Void
    
    var body: some View {
        VStack {
            GifImage(
                name: "add_to_home_screen_new",
                scrollable: true,
                in: CGSize(width: 0, height: 400)
            )
            
            Button(action: action) {
                Text("Okay")
            }
            .tint(.purple)
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
        }
        .padding()
        .presentationDetents([.fraction(0.63)])
    }
}

struct NonStickySection<V: View>: View {
    var categoryViews: [V]
    var textView: String
    var height: CGFloat? // 450 for large widget
    var showBottomSheet: Binding<Bool>
    var onTap: (() -> Void)?
    
    private let paddingHeight: CGFloat = 60.0
    
    init(
        title textView: String,
        showing categoryViews: [V],
        height: CGFloat? = nil,
        showBottomSheet: Binding<Bool>,
        onTap: (() -> Void)? = nil
    ) {
        self.categoryViews = categoryViews
        self.textView = textView
        self.height = height
        self.showBottomSheet = showBottomSheet
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 25.5) {
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
        .padding(.bottom, self.paddingHeight)
        .frame(height: self.height)
        .onTapGesture {
            withAnimation {
                showBottomSheet.wrappedValue = true
                onTap?()
            }
        }
    }
}

#Preview("All Widget Views", body: {
    AllWidgetsView()
})
