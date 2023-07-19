//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

struct MyTabView: View {
    var body: some View {
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

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("KIDA Entertainment!")
                    .font(.system(.largeTitle, design: .rounded))
                Text("One Stop Shop For Widget Entertainment!")
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 15) {
                    NavigationLink {
                        MyTabView()
                    } label: {
                        Label("Content", systemImage: "tablecells.fill")
                    }
                    
                    NavigationLink {
                        MemeGenerator()
                    } label: {
                        Label("MemeGen", systemImage: "theatermask.and.paintbrush.fill")
                    }
                    
                    NavigationLink {
                        CustomImageView(buttonAction: nil)
                    } label: {
                        Label("Widget Settings", systemImage: "gear.circle")
                    }
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.bar)
                .tint(.orange)
            }
            .padding(.vertical, 30)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
