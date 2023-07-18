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
                        .navigationTitle("Jokes")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Joke", systemImage: "theatermasks.circle.fill")
                }
                
                NavigationView {
                    QuoteView()
                        .navigationTitle("Quotes")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Quote", systemImage: "quote.bubble.fill")
                }
                
                NavigationView {
                    RedditScrapperView()
                        .navigationTitle("Photos")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Reddit", systemImage: "photo.stack.fill")
                }
                
                NavigationView {
                    NASAApodView()
                        .navigationBarTitle("NASA Picture of the day")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("NASA", systemImage: "photo.fill.on.rectangle.fill")
                }
                
                NavigationView {
                    SpeedTestView()
                        .navigationBarTitle("Speed Test")
                        .navigationBarTitleDisplayMode(.inline)
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
