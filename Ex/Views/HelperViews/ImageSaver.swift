//
//  ImageSaver.swift
//  Ex
//
//  Created by Sharan Thakur on 13/07/23.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    func saveImageContextMenu(
        completion: ((Bool) -> Void)? = nil // didSuccess
    ) -> some View {
        self.contextMenu {
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let imageSaver = ImageSaver(completion: completion)
                    imageSaver.writeToPhotoAlbum(image: self.asUiImage())
                }
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
        }
    }
}

extension View {
    func asUiImage() -> UIImage {
        var uiImage = UIImage(systemName: "exclamationmark.triangle.fill")!
        let controller = UIHostingController(rootView: self)
        
        if let view = controller.view {
            let contentSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: contentSize)
            uiImage = renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
        return uiImage
    }
}

extension Image {
    @MainActor func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}

class ImageSaver: NSObject {
    var completion: ((Bool) -> Void)?
    
    init(completion: ((Bool) -> Void)?) {
        self.completion = completion
    }
    
    func writeToPhotoAlbum(image: Image, size: CGSize) {
        Task {
            if let uiImage = await image.getUIImage(newSize: size) {
                self.writeToPhotoAlbum(image: uiImage)
            }
        }
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?(error == nil)
        if let error = error {
            print("Error Saving")
            print(error.localizedDescription)
        } else {
            print("No error")
        }
    }
}
