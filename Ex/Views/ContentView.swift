//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            JokeView()
                .tabItem {
                    Label("Joke", systemImage: "theatermasks.circle.fill")
                }
            
            QuoteView()
                .tabItem {
                    Label("Quote", systemImage: "quote.bubble.fill")
                }
        }
        //.preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
