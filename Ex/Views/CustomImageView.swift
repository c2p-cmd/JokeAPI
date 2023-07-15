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
    @State private var image: UIImage? = UIImage(systemName: "exclamationmark.triangle.fill")!
    @State private var pickedItem: PhotosPickerItem?
    @State private var error: String?
    
    var body: some View {
        VStack {
            PhotosPicker(
                "Choose an Image to show on widgets",
                selection: self.$pickedItem,
                matching: .images
            )
            if let error {
                Text(error)
                    .foregroundStyle(.primary)
            }
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(.gray)
            }
            
            Button("Reset Widget Image") {
                UIImage.resetWidgetImage()
                WidgetCenter.shared.reloadTimelines(ofKind: "Custom Picture Widget")
            }
        }
        .onAppear {
            self.error = nil
            UIImage.loadImage { savedImage in
                self.image = savedImage
            }
        }
        .onChange(of: self.pickedItem) { value in
            value?.loadTransferable(type: Data.self) { (result: Result<Data?, Error>) in
                
                switch result {
                case .success(let data):
                    self.error = nil
                    if let data {
                        if let image = UIImage(data: data, scale: 0.5) {
                            image.saveImage()
                        } else {
                            print("Issue")
                        }
                        UIImage.loadImage { newImage in
                            self.image = newImage
                        }
                        WidgetCenter.shared.reloadTimelines(ofKind: "Custom Picture Widget")
                    } else {
                        self.error = "No data found"
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
