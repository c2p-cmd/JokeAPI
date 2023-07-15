//
//  UIImage+resize.swift
//  Ex
//
//  Created by Sharan Thakur on 30/06/23.
//

import UIKit

extension UIImage {
    func saveImage() {
        let image = self.size.width > 800 ? self.resized(toWidth: 800) : self
        
        if let pngData = image.pngData() {
            appStorage.set(pngData, forKey: "IMAGE_KEY")
        } else {
            print("No png data")
        }
    }
    
    static func resetWidgetImage() {
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
