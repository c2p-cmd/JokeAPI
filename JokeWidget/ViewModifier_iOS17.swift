//
//  ViewModifier_iOS17.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import SwiftUI

struct ModifyForiOS17<S: ShapeStyle>: ViewModifier {
    var style: S
    
    func body(content: Content) -> some View {
        if #available(iOS 17, macOS 14, watchOS 10, *) {
            return content.containerBackground(style, for: .widget)
        } else {
            return content
        }
    }
}

extension View {
    func modifyForiOS17<S>(_ style: S = .black) -> some View where S: ShapeStyle {
        self.modifier(ModifyForiOS17(style: style))
    }
    
    func maybeInvalidatableContent() -> some View {
        if #available(iOS 17, macOS 14, *) {
            return self.invalidatableContent()
        } else {
            return self
        }
    }
}
