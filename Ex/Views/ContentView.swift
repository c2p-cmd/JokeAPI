//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                JokeView()
                    .tabItem {
                        Label("Joke", systemImage: "theatermasks.circle.fill")
                    }
                
                QuoteView()
                    .tabItem {
                        Label("Quote", systemImage: "quote.bubble.fill")
                    }
                
                SpeedTestView()
                    .tabItem {
                        Label("SpeedTest", systemImage: "speedometer")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
