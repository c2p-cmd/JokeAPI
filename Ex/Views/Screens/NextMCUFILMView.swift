//
//  NextMCUFILMView.swift
//  Ex
//
//  Created by Sharan Thakur on 15/08/23.
//

import SwiftUI

struct NextMCUFILMView: View {
    @AppStorage("next_mcu_film") private var film: NextMcuFilm?
    @State private var pickerDate: Date = .now
    @State private var error: String?
    
    private func releaseDate(_ film: NextMcuFilm) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: film.releaseDate)
    }
    
    var body: some View {
        List {
            HStack {
                Text("Hello World!")
                Spacer()
                Button(action: makeReq) {
                    Text("Get Next Film")
                }
                .buttonStyle(.bordered)
            }
            
            DatePicker(
                "Date Picker",
                selection: $pickerDate,
                displayedComponents: [.date]
            )
            
            if let nextMcuFilm = film {
                VStack(spacing: 5) {
                    Text(nextMcuFilm.daysUntil.description)
                    
                    Text(nextMcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                    
                    AsyncImage(url: URL(string: nextMcuFilm.posterUrl)) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 100)
                            .padding()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("\(nextMcuFilm.type): \(nextMcuFilm.title)")
                    Text(nextMcuFilm.overview)
                }
            }
            
            if let error {
                Text(error)
                    .tint(.red)
            }
        }
        .listStyle(.plain)
        .padding()
        
    }
    
    private func makeReq() {
        getNextMCUFilm(on: self.pickerDate) { result in
            switch result {
            case .success(let newResponse):
                self.film = newResponse
                break
            case .failure(let error):
                self.error = error.localizedDescription
                break
            }
        }
    }
}

#Preview {
    NextMCUFILMView()
}
