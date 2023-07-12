//
//  QuoteView.swift
//  Ex
//
//  Created by Sharan Thakur on 28/06/23.
//

import WidgetKit
import SwiftUI

struct QuoteView: View {
    @AppStorage("quote") private var quote = UserDefaults.defaultQuote
    
    @State private var isBusy = false
    @State private var error: String? = nil
    
    private let greenGradient = LinearGradient(
        colors: [
            Color("Green 1", bundle: .main),
            Color("Green 2", bundle: .main)
        ],
        startPoint: .bottom, endPoint: .top
    )
    
    var body: some View {
        VStack {
            Spacer()
            
            Section {
                widgetView
            } header: {
                Text("Widget View")
                    .foregroundStyle(.secondary)
            } footer: {
                RefreshButton(
                    isBusy: self.$isBusy,
                    action: getNewQuote
                )
            }
            
            if let err = error {
                Spacer()
                Text(err)
                    .font(.callout)
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
    
    private var widgetView: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .fill(greenGradient)
            VStack {
                Text(quote.content)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.leading)
                HStack() {
                    Spacer()
                    Text("-\(quote.author)")
                        .font(.system(.subheadline, design: .rounded))
                        .multilineTextAlignment(.trailing)
                        .padding(.all, 25)
                }
            }
            .foregroundStyle(.white)
            .bold()
        }
        .frame(width: 360, height: 169)
    }
    
    private func getNewQuote() {
        if isBusy {
            return
        }
        
        Task {
            isBusy = true
            let result = await getRandomQuote()
            switch result {
            case .success(let newQuote):
                self.error = nil
                self.quote = newQuote
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteWidget")
                break
            case .failure(let err):
                self.error = err.localizedDescription
                break
            }
            isBusy = false
        }
    }
}
