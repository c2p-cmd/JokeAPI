//
//  ViewModifier_iOS17.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import SwiftUI

struct ModifyForiOS17: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17, macOS 14, *) {
            return content.containerBackground(.fill.tertiary, for: .widget)
        } else {
            return content
        }
    }
}

extension View {
    func modifyForiOS17() -> some View {
        self.modifier(ModifyForiOS17())
    }
}
