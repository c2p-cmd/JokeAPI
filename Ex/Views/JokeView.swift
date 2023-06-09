//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

struct JokeView: View {
    @State private var joke: String = "Why do Java Programmers have to wear glasses?\n\nBecause they don't C#."
    @State private var makignRequest = false
    @State private var error: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(joke)
                .font(.title2)
                .monospaced()
                .multilineTextAlignment(.center)
            if let err = error {
                Text(err)
                    .font(.caption2)
                    .monospaced()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if makignRequest {
                        return
                    }
                    showJoke()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }.disabled(makignRequest)
            }
        }
        .onAppear {
            showJoke()
        }
    }
    
    func getSavedJoke() {
        // TODO: use UserDefaults
    }

    func showJoke() {
        Task {
            makignRequest = true
            let result = await getRandomJoke()
            joke = try result.get()
            makignRequest = false
        }
    }
}