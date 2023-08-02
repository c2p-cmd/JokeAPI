//
//  HelperViews.swift
//  Ex
//
//  Created by Sharan Thakur on 12/07/23.
//

import SwiftUI
import WidgetKit

struct GenericWidgetView<V1: View, V2: View>: View {
    @ViewBuilder var backgroundImage: V1
    @ViewBuilder var textView: V2
    var widgetFamily: WidgetFamily = .systemMedium
    
    var body: some View {
        ZStack {
            backgroundImage
                .scaledToFill()
                .modifier(ModifyForWidgetViewFrame(widgetFamily: self.widgetFamily))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 5,
                    x: 0,
                    y: 5
                )
            
            textView
                .padding(.all, 15)
        }
        .modifier(ModifyForWidgetViewFrame(widgetFamily: self.widgetFamily))
        .background(.clear)
    }
}

struct ModifyForWidgetViewFrame: ViewModifier {
    var widgetFamily: WidgetFamily = .systemMedium
    
    func body(content: Content) -> some View {
        switch self.widgetFamily {
        case .systemSmall:
            content
                .frame(width: 164.3, height: 164.3, alignment: .leading)
        case .systemMedium:
            content
                .frame(width: 345, height: 162, alignment: .leading)
        case .systemLarge:
            content
                .frame(width: 345, height: 360, alignment: .leading)
        default:
            content
        }
    }
}

struct WidgetView: View {
    @Binding var joke: String
    
    var yellowGradient = LinearGradient(
        colors: [
            Color("YellowColor", bundle: .main),
            Color("YellowColor 1", bundle: .main)
        ],
        startPoint: .bottom, endPoint: .top
    )
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .fill(yellowGradient)
            Text(joke)
                .foregroundStyle(.black)
                .font(.system(.body, design: .rounded))
                .bold()
                .multilineTextAlignment(.leading)
                .padding(.all, 25)
        }
        .frame(width: 360, height: 169)
    }
}

struct RefreshButton: View {
    @Binding var isBusy: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .foregroundColor(.blue)
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
        }
        .disabled(isBusy)
        .buttonStyle(.plain)
    }
}
