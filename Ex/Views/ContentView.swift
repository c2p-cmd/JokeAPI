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
            VStack(alignment: .center) {
                Text("KIDA Entertainment!")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 25.0) {
                    Text("Your One Stop Shop For Widget Entertainment!")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.bottom, 55.0)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        AllWidgetsView()
                            .navigationTitle("All Widgets")
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Label("All Widgets View", systemImage: "arrow.forward.circle")
                            .foregroundStyle(.black)
                    }
                    .clipShape(Circle())
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.bar)
                .tint(.orange)
                
                Spacer()
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 10)
            .background(backGround())
        }
    }
    
    private func backGround() -> some View {
        let gradient = LinearGradient(
            colors: [.cyan, .blue],
            startPoint: .top,
            endPoint: .bottom
        )
        
        return Image("Main_BG")
            .resizable()
            .opacity(0.69)
            .scaledToFill()
            .ignoresSafeArea()
            .background(gradient)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
