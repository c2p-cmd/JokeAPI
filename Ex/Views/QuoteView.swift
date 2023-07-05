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
        NavigationView {
            VStack {
                refreshButton
                Spacer()
                widgetView
                if let err = error {
                    Spacer()
                    Text(err)
                        .font(.callout)
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Quotes View")
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
                }
            }
            .foregroundStyle(.white)
            .bold()
            .padding(.horizontal, 7.5)
        }
        .frame(width: 360, height: 169)
    }
    
    private var refreshButton: some View {
        HStack {
            Spacer()
            Button {
                if isBusy == false {
                    getNewQuote()
                }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
            }
            .disabled(self.isBusy)
        }
    }
    
    private func getNewQuote() {
        isBusy = true
        Task {
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

//struct QuoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuoteView()
//    }
//}
