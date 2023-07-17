//
//  CustomImageView.swift
//  Ex
//
//  Created by Sharan Thakur on 15/07/23.
//

import SwiftUI
import PhotosUI
import WidgetKit

struct CustomImageView: View {
    var buttonAction: () -> Void
    
    @State private var images: [UIImage] = []
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Button("Close", action: self.buttonAction)
                Spacer()
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            PhotosPicker(
                "Choose an image (or images) to show on widgets",
                selection: self.$pickedItems,
                matching: .images
            )
            
            if let error {
                Text(error)
                    .foregroundStyle(.primary)
            }
            
            if self.images.isEmpty {
                Text("No Images chosen")
            } else if images.count == 1 {
                Image(uiImage: images[0])
                    .resizable()
                    .scaledToFit()
                    .background(.gray)
                    .tag(images[0].hash)
                    .frame(height: 500)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(self.images, id: \.self) {
                            Image(uiImage: $0)
                                .resizable()
                                .scaledToFit()
                                .background(.gray)
                                .tag($0.hash)
                        }
                    }
                }
                .frame(height: 500)
            }
            Spacer()
            
            HStack(spacing: 25) {
                Button("Reset Widget Image") {
                    UIImage.resetWidgetImage()
                    self.images.removeAll()
                    WidgetCenter.shared.reloadTimelines(ofKind: "Custom Picture Widget")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Refresh Widget") {
                    WidgetCenter.shared.reloadTimelines(ofKind: "Custom Picture Widget")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            self.error = nil
            UIImage.loadImages(onSuccess: { savedImages in self.images = savedImages }, onError: nil)
        }
        .onChange(of: self.pickedItems) { (items: [PhotosPickerItem]) in
            if items.isEmpty {
                return
            }
            
            let lastIndex = items.count - 1
            for (itemIndex, photoPickerItem) in items.enumerated() {
                photoPickerItem.loadTransferable(type: Data.self) { (result: Result<Data?, Error>) in
                    
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            if let data {
                                self.error = nil
                                if let image = UIImage(data: data) {
                                    images.append(image)
                                    
                                    if itemIndex == lastIndex {
                                        self.pickedItems.removeAll()
                                        UIImage.saveImages(self.images)
                                        WidgetCenter.shared.reloadTimelines(ofKind: "Custom Picture Widget")
                                    }
                                } else {
                                    print("Issue")
                                }
                            } else {
                                self.error = "No data found"
                            }
                        }
                        break
                    case .failure(let err):
                        self.error = err.localizedDescription
                        break
                    }
                }
            }
        }
    }
}
