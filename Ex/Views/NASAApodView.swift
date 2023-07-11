//
//  NASAApodView.swift
//  Ex
//
//  Created by Sharan Thakur on 11/07/23.
//

import SwiftUI
import WidgetKit

struct NASAApodView: View {
    @AppStorage("nasa_apod") private var apodResponse: ApodResponse?
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var selectedDate: Date = .now
    
    var body: some View {
        List {
            DatePicker("Date of Image", selection: $selectedDate, displayedComponents: .date)
            if let apodResponse = apodResponse {
                Text(apodResponse.title)
                    .font(.system(.headline, design: .rounded))
                
                if let image = apodResponse.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    AsyncImage(url: URL(string: apodResponse.url)) { imagePhase in
                        imagePhase.resizable()
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                    .scaledToFit()
                }
                
                Text(apodResponse.explanation)
                    .font(.system(.body, design: .rounded))
            }
            
            if let error = error {
                Text(error)
                    .font(.footnote)
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    getNewImage()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    func getNewImage() {
        if isBusy {
            return
        }
        
        Task {
            isBusy = true
            
            let result = await getNASAApod(on: self.selectedDate)
            
            switch result {
            case .success(let apodResonse):
                self.error = nil
                self.apodResponse = apodResonse
                WidgetCenter.shared.reloadTimelines(ofKind: "NASA Apod Widget")
                break
            case .failure(let error):
                self.error = error.localizedDescription
                break
            }
            
            isBusy = false
        }
    }
}
