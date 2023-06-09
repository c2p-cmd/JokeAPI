//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI
import WidgetKit

struct JokeView: View {
    @State private var joke: String = ""
    @State private var isBusy = false
    @State private var error: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(joke)
                .font(.title2)
                .monospaced()
                .multilineTextAlignment(.center)
            if let err = error {
                Spacer()
                Text(err)
                    .font(.caption2)
                    .monospaced()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isBusy {
                        return
                    }
                    getSavedJoke(doFetch: true)
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }.disabled(isBusy)
            }
        }
        .onAppear {
            getSavedJoke()
        }
    }
    
    func getSavedJoke(doFetch: Bool = false) {
        joke = UserDefaults.savedJoke
        if doFetch == false {
            return
        }
        Task {
            isBusy = true
            let result = await getRandomJoke()
            switch result {
            case .success(let newJoke):
                joke = newJoke
                WidgetCenter.shared.reloadAllTimelines()
                break
            case .failure(let err):
                self.error = err.localizedDescription
                break
            }
            isBusy = false
        }
    }
}
