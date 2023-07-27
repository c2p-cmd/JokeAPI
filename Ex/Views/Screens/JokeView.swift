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
    @AppStorage("safe_mode") private var safeMode: Bool = true
    @AppStorage("joke_type") private var jokeType: JokeType = .any
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var selectedCategories: Set<IdentifiableString> = Set()
    
    var body: some View {
        VStack {
            List {
                MultiSelectionMenu(
                    label: "Joke Category",
                    selectedCategories: self.$selectedCategories,
                    availableCategories: Array(jokeCategories)
                )
                
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
                        .bold()
                }
                
                Section {
                    WidgetView(joke: self.$joke)
                } header: {
                    Text("Widget View")
                        .foregroundStyle(.secondary)
                } footer: {
                    HStack {
                        Spacer()
                        RefreshButton(isBusy: self.$isBusy, action: getNewJoke)
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
            getNewJoke()
        }
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
