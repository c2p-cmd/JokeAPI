//
//  PexelsView.swift
//  Ex
//
//  Created by Sharan Thakur on 13/07/23.
//

import SwiftUI
import WidgetKit

struct PexelsView: View {
    @AppStorage("pexels_photo") private var pexelsPhotoResponse: MultiPhotoResponse = UserDefaults.savedPexelsPhotoResponse
    
    private let categories: [String] = [
        "animal",
        "bikes",
        "cars",
        "vintage vehicles"
    ]
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var isPresenting = false
    @State private var alertText = "Success"
    @State private var image: UIImage?
    
    @State private var selectedCategory = "animal"
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            List {
                if let error = error {
                    Text(error)
                        .font(.footnote)
                }
                
                Picker("Choose Category", selection: self.$selectedCategory) {
                    ForEach(categories, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
                .pickerStyle(.menu)
                
                if let image {
                    Section("Loaded Image") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                
                Section {
                    TabView {
                        ForEach(pexelsPhotoResponse.photos, id: \.id) {
                            AsyncImage(url: $0.imageUrl) { imagePhase in
                                imagePhase
                                    .resizable()
                                    .contextMenu {
                                        Button {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                let uiImage = imagePhase.asUiImage()
                                                uiImage.saveImage { didSuccess in
                                                    alertText = didSuccess ? "Success" : "Could not set image as widget"
                                                    isPresenting = true
                                                    
                                                    if didSuccess {
                                                        WidgetCenter.shared.reloadTimelines(ofKind: "Custom Image Widget")
                                                    }
                                                }
                                            }
                                        } label: {
                                            Label("Show on widget", systemImage: "pawprint.circle")
                                        }

                                        Divider()
                                        
                                        Button {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                let imageSaver = ImageSaver(completion: saveImageCompletion(didSuccess:))
                                                imageSaver.writeToPhotoAlbum(image: imagePhase.asUiImage())
                                            }
                                        } label: {
                                            Label("Save", systemImage: "square.and.arrow.down")
                                        }
                                    }
                                    .aspectRatio(1.0, contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 100, height: 100)
                            }
                            .scaledToFill()
                        }
                    }
                    .frame(width: w, height: 450)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                } header: {
                    Text("Pictures of \(selectedCategory)")
                } footer: {
                    HStack {
                        RefreshButton(isBusy: self.$isBusy) {
                            getNewImage()
                        }
                        
                        RefreshButton(isBusy: self.$isBusy) {
                            UIImage.loadImage { image in
                                self.image = image
                                print("Loaded")
                                WidgetCenter.shared.reloadTimelines(ofKind: "Custom Image Widget")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .listStyle(.plain)
        .refreshable {
            getNewImage()
        }
        .alert(alertText, isPresented: $isPresenting) {
            Button(role: .cancel) {
                self.isPresenting = false
            } label: {
                Text("Okay")
            }
        }
        .onAppear {
            UIImage.loadImage { image in
                self.image = image
                print("Loaded \(String(describing: image))")
            }
        }
    }
    
    func saveImageCompletion(didSuccess: Bool) {
        isPresenting = true
        alertText = didSuccess ? "Success" : "Saving Failed"
    }
    
    func getNewImage() {
        if isBusy {
            return
        }
        
        Task {
            isBusy = true
            let result = await getPexelPhoto(for: self.selectedCategory)
            
            switch result {
            case .success(let newResponse):
                self.error = nil
                self.pexelsPhotoResponse = newResponse
                break
            case .failure(let err):
                self.error = err.localizedDescription
                break
            }
            
            isBusy = false
        }
    }
}
