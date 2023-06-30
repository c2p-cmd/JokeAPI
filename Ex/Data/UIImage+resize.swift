//
//  UIImage+resize.swift
//  Ex
//
//  Created by Sharan Thakur on 30/06/23.
//

import UIKit

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
