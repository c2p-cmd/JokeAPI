//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI
import WidgetKit

struct JokeView: View {
    @AppStorage("new_joke") private var joke: String = UserDefaults.savedJoke
    @State private var safeMode: Bool = true
    @State private var jokeType: JokeType = .any
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var selectedCategories: Set<IdentifiableString> = Set()
    @State private var selectedCategory = jokeCategories.first!
    
    var body: some View {
        VStack {
            List {
//                MultiSelectionMenu(
//                    label: "Joke Category",
//                    selectedCategories: self.$selectedCategories,
//                    availableCategories: Array(jokeCategories)
//                )
                Picker(selection: $selectedCategory) {
                    ForEach(Array(jokeCategories), id: \.self) {
                        Text($0.string)
                            .tag($0.hashValue)
                    }
                } label: {
                    Text("Joke Category")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                
                Picker(selection: self.$jokeType) {
                    ForEach(JokeType.allCase, id: \.self) {
                        Text($0.description)
                            .tag($0.hashValue)
                    }
                } label: {
                    Text("Joke Type")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .pickerStyle(.menu)
                
                Toggle(isOn: self.$safeMode) {
                    Text("Safe Mode")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                
                Section {
                    WidgetView(joke: self.$joke)
                } header: {
                    Text("Widget View")
                        .foregroundStyle(.secondary)
                } footer: {
                    HStack {
                        Spacer()
                        RefreshButton(isBusy: self.$isBusy, action: getNewJokeFromUs)
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
            
            if let error = error {
                Spacer()
                Text(error)
                    .font(.subheadline)
            }
            Spacer()
        }
        .refreshable {
//            getNewJoke()
            getNewJokeFromUs()
        }
    }
    
    private func getNewJokeFromUs() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        let url = URL(string: "http://192.168.0.179:8000/master/random_joke/\(self.selectedCategory.string)/")!
        
        URLSession.shared.dataTask(with: url) {
            (data: Data?, _: URLResponse?, error: Error?) in
            
            if let error {
                self.error = error.localizedDescription
            }
            
            if let data {
                self.error = nil
                self.joke = String(decoding: data, as: UTF8.self)
            }
            isBusy = false
        }.resume()
    }
    
    private func getNewJoke() {
        if isBusy {
            return
        }
        
        Task {
            isBusy = true
            let result = await getRandomJoke(
                of: Array(self.selectedCategories),
                type: self.jokeType,
                safeMode: self.safeMode
            )
            switch result {
            case .success(let newJoke):
                self.error = nil
                joke = newJoke
                WidgetCenter.shared.reloadTimelines(ofKind: "JokeWidget")
                break
            case .failure(let err):
                self.error = err.localizedDescription
                break
            }
            isBusy = false
        }
    }
}

#Preview {
    JokeView()
}
