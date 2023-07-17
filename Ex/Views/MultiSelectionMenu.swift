//
//  MultiSelectionMenu.swift
//  Ex
//
//  Created by Sharan Thakur on 12/07/23.
//

import SwiftUI

struct MultiSelectionMenu: View {
    var label: String
    @Binding var selectedCategories: Set<IdentifiableString>
    var availableCategories: [IdentifiableString]
    
    private var formattedSelectedListString: String {
        ListFormatter.localizedString(
            byJoining: selectedCategories.isEmpty ?
                ["Any"] : selectedCategories.map { $0.string }
        )
    }
    
    var body: some View {
        Menu(content: {
            Section {
                ForEach(self.availableCategories) { category in
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
                Text(self.label)
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.trailing)
            }
        })
    }
}

