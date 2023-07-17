//
//  UIImage+resize.swift
//  Ex
//
//  Created by Sharan Thakur on 30/06/23.
//

import UIKit

extension UIImage {
    var resizedForWidget: UIImage {
        self.size.width > 800 ? self.resized(toWidth: 800) : self
    }
    
    static func saveImages(_ images: [UIImage]) {
        if images.isEmpty {
            print("EMPTY ARRAY OF IMAGES")
            return
        }
        
        // mapping to make sure resized properly & getting only data of the images which are not nil
        let imageArray: [Data] = images.compactMap { uiImage in uiImage.resizedForWidget.pngData() }
        
        if imageArray.isEmpty {
            print("EMPTY ARRAY OF IMAGE DATA")
            return
        }
        
        appStorage.set(imageArray, forKey: "IMAGES_KEY")
    }
    
    static func loadImages(
        onSuccess: @escaping ([UIImage]) -> Void,
        onError: @escaping () -> Void
    ) {
        guard let 👻 = appStorage.array(forKey: "IMAGES_KEY") as? [Data] else {
            onError()
            return
        }
        
        let 🎞️: [UIImage] = 👻.compactMap { UIImage(data: $0) }
        
        if 🎞️.isEmpty {
            print("loading: EMPTY ARRAY OF IMAGES")
            onError()
            return
        }
        
        onSuccess(🎞️)
    }
    
    func saveImage() {
        let image = self.resizedForWidget
        
        if let pngData = image.pngData() {
            appStorage.set(pngData, forKey: "IMAGE_KEY")
        } else {
            print("No png data")
        }
    }
    
    static func resetWidgetImage() {
        appStorage.removeObject(forKey: "IMAGES_KEY")
        appStorage.removeObject(forKey: "IMAGE_KEY")
    }
    
    static func loadImage(
        completion: @escaping (UIImage) -> Void
    ) {
        guard let data = appStorage.data(forKey: "IMAGE_KEY") else {
            completion(UIImage(systemName: "exclamationmark.triangle.fill")!)
            return
        }
        let uiImage = UIImage(data: data) ?? UIImage(systemName: "exclamationmark.triangle.fill")!
        print("Setting image: \(uiImage.debugDescription) from: \(data.debugDescription)")
        completion(uiImage)
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
