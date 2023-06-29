//
//  ContentView.swift
//  JokeApp
//
//  Created by kida-macbook-air on 27/06/23.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("joke") private var joke: String = ""
    @State private var error: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text(joke)
                
                if let error = error {
                    Text(error)
                }
                
                Button(action: {
                    Task {
                        let jokeRes = await getRandomJoke()
                        switch jokeRes {
                        case .success(let newJoke):
                            joke = newJoke
                            error = nil
                            WidgetCenter.shared.reloadAllTimelines()
                            break
                        case .failure(let error):
                            self.error = error.localizedDescription
                            break
                        }
                    }
                }, label: {
                    Text("Fetch")
                })
            }
        }
        .padding()
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
