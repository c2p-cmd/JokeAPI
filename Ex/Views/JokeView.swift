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
    @State private var selectedCategories = Set([].map { IdentifiableString(string: $0) })
    
    private let yellowGradient = LinearGradient(
        colors: [
            Color("YellowColor", bundle: .main),
            Color("YellowColor 1", bundle: .main)
        ],
        startPoint: .bottom, endPoint: .top
    )
    
    var body: some View {
        NavigationView {
            VStack {
                refreshButton
                MultiSelector<Text, IdentifiableString>(
                    label: labelView("Choose Joke Categories"),
                    options: jokeCategories.map { IdentifiableString(string: $0) },
                    optionToString: { $0.string },
                    selected: self.$selectedCategories,
                    emptySelectionString: "Any"
                )
                Toggle(isOn: self.$safeMode) {
                    labelView("Safe Mode")
                }
                Spacer()
                widgetView
                if let error = error {
                    Spacer()
                    Text(error)
                        .font(.subheadline)
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Jokes View")
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
        HStack {
            Spacer()
            Button {
                if isBusy == false {
                    getNewJoke()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }.disabled(isBusy)
        }
    }
    
    private func labelView(_ title: String) -> Text {
        Text(title)
            .font(.title3)
            .bold()
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
