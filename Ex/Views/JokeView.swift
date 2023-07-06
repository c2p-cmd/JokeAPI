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
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var selectedCategories: Set<IdentifiableString> = Set()
    
    private let yellowGradient = LinearGradient(
        colors: [
            Color("YellowColor", bundle: .main),
            Color("YellowColor 1", bundle: .main)
        ],
        startPoint: .bottom, endPoint: .top
    )
    
    var body: some View {
        VStack {
            List {
                MultiSelectionMenu(selectedCategories: self.$selectedCategories)
                
                Toggle(isOn: self.$safeMode) {
                    Text("Safe Mode")
                        .bold()
                }
                
                Section("Widget View") {
                    widgetView
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                refreshButton
            }
        }
        .refreshable {
            if isBusy == false {
                getNewJoke()
            }
        }
    }
    
    private var widgetView: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .fill(yellowGradient)
            Text(joke)
                .foregroundStyle(.black)
                .font(.system(.body, design: .rounded))
                .bold()
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 7.5)
        }
        .frame(width: 360, height: 169)
    }
    
    private var refreshButton: some View {
        Button {
            print("New Joke")
            if isBusy == false {
                getNewJoke()
            }
        } label: {
            Label("Reload", systemImage: "arrow.clockwise")
        }.disabled(isBusy)
    }
    
    private func getNewJoke() {
        Task {
            isBusy = true
            let result = await getRandomJoke(
                of: Array(self.selectedCategories),
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

struct MultiSelectionMenu: View {
    @Binding var selectedCategories: Set<IdentifiableString>
    
    private var formattedSelectedListString: String {
        ListFormatter.localizedString(
            byJoining: selectedCategories.isEmpty ?
                ["Any"] : selectedCategories.map { $0.string }
        )
    }
    
    var body: some View {
        Menu(content: {
            Section {
                ForEach(Array(jokeCategories)) { category in
                    Button {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    } label: {
                        HStack {
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }
                            Text(category.string)
                        }
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    selectedCategories.removeAll()
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Spacer()
                        Text("Clear All")
                    }
                }
            }
        }, label: {
            HStack {
                Text("Joke Categories")
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.trailing)
            }
        })
    }
}
