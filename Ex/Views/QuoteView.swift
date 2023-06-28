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
    
    var body: some View {
        NavigationView {
            Form {
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
                Text(quote.content)
                    .font(.title2)
                    .monospaced()
                    .multilineTextAlignment(.center)
                HStack() {
                    Spacer()
                    Text("-\(quote.author)")
                        .font(.title3)
                        .monospaced()
                        .multilineTextAlignment(.leading)
                }
                if let err = error {
                    Text(err)
                        .font(.callout)
                }
            }
        }
        .navigationTitle("Quotes View")
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
