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
    var buttonAction: (() -> Void)?
    
    @State private var image: UIImage? = nil
    @State private var pickedItems: PhotosPickerItem? = nil
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 10) {
            if let buttonAction = self.buttonAction {
                HStack(alignment: .top) {
                    Button("Close", action: buttonAction)
                    Spacer()
                }
                .padding(.horizontal, 15)
            }
            
            Spacer()
            
            PhotosPicker(
                "Choose an image to show on widgets",
                selection: self.$pickedItems,
                matching: .images
            )
            
            if let error {
                Text(error)
                    .foregroundStyle(.primary)
            }
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(.gray)
                    .frame(height: 500)
            } else {
                Text("No Image Chosen")
            }
            Spacer()
            
            HStack(spacing: 25) {
                Button("Reset Widget Image") {
                    UIImage.resetWidgetImage()
                    self.image = nil
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
            UIImage.loadImage { savedImage in
                self.image = savedImage
            }
            // UIImage.loadImages(onSuccess: { savedImages in self.images = savedImages }, onError: nil)
        }
        .onChange(of: self.pickedItems) { (photoPickerItem: PhotosPickerItem?) in
            photoPickerItem?.loadTransferable(type: Data.self) { (result: Result<Data?, Error>) in
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        if let data {
                            self.error = nil
                            if let image = UIImage(data: data) {
                                withAnimation {
                                    self.image = image.resizedForWidget
                                    image.resizedForWidget.saveImage()
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
