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
    
    @State private var isBusy = false
    @State private var error: String?
    @State private var isPresenting = false
    @State private var alertText = "Success"
    
    @State private var showingFullScreenCover = false
    
    @State private var pexelPhotoPage = 1
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let _ = proxy.size.height
            
            List {
                if let error = error {
                    Text(error)
                        .font(.footnote)
                }
                
                Section {
                    TabView {
                        ForEach(pexelsPhotoResponse.photos, id: \.id) {
                            AsyncImage(url: $0.imageUrl) { imagePhase in
                                imagePhase
                                    .resizable()
                                    .saveImageContextMenu(completion: saveImageCompletion(didSuccess:))
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
                    Text("Pictures of animals")
                } footer: {
                    Text("Hold on any image to save in your gallery")
                        .foregroundStyle(.tertiary)
                        .font(.footnote)
                }
                
                HStack {
                    Spacer()
                    RefreshButton(isBusy: self.$isBusy) {
                        getNewImage()
                    }
                    Spacer()
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
            self.pexelPhotoPage = 1
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    self.showingFullScreenCover = true
                }, label: {
                    Label("Set custom image widget.", systemImage: "gear.circle")
                })
            }
        }
        .fullScreenCover(isPresented: self.$showingFullScreenCover) {
            CustomImageView(buttonAction: {
                self.showingFullScreenCover = false
            })
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
            self.pexelPhotoPage += 1
            isBusy = true
            let result = await getPexelPhoto(page: self.pexelPhotoPage)
            
            switch result {
            case .success(let newResponse):
                self.error = nil
                self.pexelsPhotoResponse = newResponse
                WidgetCenter.shared.reloadTimelines(ofKind: "Pexel Animal Image Widget")
                break
            case .failure(let err):
                self.pexelPhotoPage = 1
                self.error = err.localizedDescription
                break
            }
            
            isBusy = false
        }
    }
}
