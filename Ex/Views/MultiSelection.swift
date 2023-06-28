//
//  MultiSelection.swift
//  Ex
//
//  Created by Sharan Thakur on 28/06/23.
//

import SwiftUI

struct IdentifiableString: Identifiable, Hashable {
    let string: String
    var id: String { string }
}

struct MultiSelectionView<Selectable: Identifiable & Hashable>: View {
    let options: [Selectable]
    let optionToString: (Selectable) -> String

    @Binding var selected: Set<Selectable>

    var body: some View {
        List {
            ForEach(options) { selectable in
                Button {
                    toggleSelection(selectable: selectable)
                } label: {
                    HStack {
                        Text(optionToString(selectable)).foregroundColor(.black)
                        Spacer()
                        if selected.contains(where: { $0.id == selectable.id }) {
                            Image(systemName: "checkmark").foregroundColor(.accentColor)
                        }
                    }
                }.tag(selectable.id)
            }
            Button("Clear All", role: .destructive) {
                selected.removeAll()
            }
        }.listStyle(GroupedListStyle())
    }

    private func toggleSelection(selectable: Selectable) {
        if let existingIndex = selected.firstIndex(where: { $0.id == selectable.id }) {
            selected.remove(at: existingIndex)
        } else {
            selected.insert(selectable)
        }
    }
}

struct MultiSelector<LabelView: View, Selectable: Identifiable & Hashable>: View {
    let label: LabelView
    let options: [Selectable]
    let optionToString: (Selectable) -> String

    var selected: Binding<Set<Selectable>>
    var emptySelectionString: String = ""

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(
            byJoining: selected.wrappedValue.isEmpty ? [emptySelectionString] : selected.wrappedValue.map { optionToString($0) }
        )
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                label
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(
            options: options,
            optionToString: optionToString,
            selected: selected
        )
    }
}

struct Example_View: View {
    @State var selected: Set<IdentifiableString> = Set(["A", "C"].map { IdentifiableString(string: $0) })
    
    var body: some View {
        NavigationView {
            Form {
                MultiSelector<Text, IdentifiableString>(
                    label: Text("Multiselect"),
                    options: ["A", "B", "C", "D"].map { IdentifiableString(string: $0) },
                    optionToString: { $0.string },
                    selected: $selected
                )
            }.navigationTitle("Title")
        }
    }
}

//struct MultiSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        Example_View()
//    }
//}
