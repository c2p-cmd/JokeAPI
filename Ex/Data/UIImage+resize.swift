//
//  UIImage+resize.swift
//  Ex
//
//  Created by Sharan Thakur on 30/06/23.
//

import UIKit

extension UIImage {
    func saveImage(
        completion: @escaping (Bool) -> Void
    ) {
        guard let data = self.jpegData(compressionQuality: 0.5) else {
            completion(false)
            return
        }
        let encoded = try! PropertyListEncoder().encode(data)
        appStorage.set(encoded, forKey: "image_key")
        completion(true)
    }

    static func loadImage(
        completion: @escaping (UIImage) -> Void
    ) {
        guard let data = appStorage.data(forKey: "image_key") else {
            completion(UIImage(systemName: "exclamationmark.triangle.fill")!)
            return
        }
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        completion(UIImage(data: decoded) ?? UIImage(systemName: "exclamationmark.triangle.fill")!)
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
