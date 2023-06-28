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
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Spacer()
                    Button {
                        if isBusy == false {
                            getNewJoke()
                        }
                    } label: {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }.disabled(isBusy)
                }
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
                Text(joke)
                    .font(.title2)
                    .monospaced()
                    .multilineTextAlignment(.center)
                if let err = error {
                    Spacer()
                    Text(err)
                        .font(.caption2)
                }
            }
        }
        .navigationTitle("Jokes View")
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

//struct JokeView_Previews: PreviewProvider {
//    static var previews: some View {
//            JokeView()
//    }
//}
