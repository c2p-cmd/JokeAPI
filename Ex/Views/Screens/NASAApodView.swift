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
    @State private var isPresenting = false
    @State private var alertText = "Success"
    @State private var alertDescription = "Success"
    
    var body: some View {
        List {
            DatePicker(
                "Date of Image",
                selection: $selectedDate,
                in: ...Date.now,
                displayedComponents: .date
            )
            
            if let error = error {
                Text(error)
                    .font(.footnote)
            }
            
            if let apodResponse = apodResponse {
                Text(apodResponse.title)
                    .font(.system(.headline, design: .rounded))
                
                AsyncImage(url: URL(string: apodResponse.url)) { imagePhase in
                    imagePhase.resizable().saveImageContextMenu { (didSucess: Bool, error: String) in
                        if didSucess {
                            self.alertText = "Success!"
                            self.alertDescription = "This image has been saved in your gallery!"
                        } else {
                            self.alertText = "Failed"
                            self.alertDescription = "This image couldn't be saved in your gallery. \(error)"
                        }
                        self.isPresenting = didSucess
                    }
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 100, height: 100)
                }
                .scaledToFit()
                
                Text(apodResponse.explanation)
                    .font(.system(.body, design: .rounded))
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                RefreshButton(isBusy: self.$isBusy, action: getNewImage)
            }
        }
        .alert(alertText, isPresented: $isPresenting) {
            Button(role: .cancel) {
                self.isPresenting = false
            } label: {
                Text("Okay")
            }
        } message: {
            Text(self.alertDescription)
        }
        .refreshable {
            getNewImage()
        }
        .onAppear {
            if self.apodResponse == nil {
                getNewImage()
            }
        }
    }
    
    func getNewImage() {
        if selectedDate > .now {
            selectedDate = .now
        }
        
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let savedDate = dateFormatter.date(from: apodResonse.date) {
                    self.selectedDate = savedDate
                }
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