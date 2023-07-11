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
                NavigationView {
                    JokeView()
                        .navigationBarTitle("Jokes", displayMode: .inline)
                }
                .tabItem {
                    Label("Joke", systemImage: "theatermasks.circle.fill")
                }
                
                NavigationView {
                    QuoteView()
                        .navigationBarTitle("Quotes", displayMode: .inline)
                }
                .tabItem {
                    Label("Quote", systemImage: "quote.bubble.fill")
                }
                
                NavigationView {
                    NASAApodView()
                        .navigationBarTitle("NASA Picture of the day", displayMode: .inline)
                }
                .tabItem {
                    Label("NASA", systemImage: "photo.fill.on.rectangle.fill")
                }
                
                NavigationView {
                    SpeedTestView()
                        .navigationBarTitle("Speed Test", displayMode: .inline)
                }
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
