//
//  HelperViews.swift
//  Ex
//
//  Created by Sharan Thakur on 12/07/23.
//

import SwiftUI

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
