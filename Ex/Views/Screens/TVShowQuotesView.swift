//
//  TVShowQuotesView.swift
//  Ex
//
//  Created by Sharan Thakur on 11/08/23.
//

import SwiftUI

struct TVShowQuotesView: View {
    @State private var selectedTvShow = TVShowQuoteResponses.allShows.randomElement()!
    @State private var error: String? = nil
    @State private var isBusy: Bool = false
    @State private var shortQuote: Bool = true
    @AppStorage("tv_show_quotes") private var responses: TVShowQuoteResponses = [TVShowQuoteResponse]()
    @State private var count = 1
    
    var body: some View {
        List {
            Toggle("Short Quote?", isOn: self.$shortQuote)
            
            Picker("Quote Count", selection: self.$count) {
                let range = 1...10
                
                ForEach(range, id: \.self) { i in
                    Text(i.description)
                }
            }
            
            Picker("TV Show", selection: self.$selectedTvShow) {
                ForEach(TVShowQuoteResponses.allShows, id: \.self) { tvShow in
                    Text(tvShow)
                }
            }
            
            if responses.isNotEmpty {
                ForEach(responses, id: \.id) { tvShowQuote in
                    Text(tvShowQuote.text)
                        .textSelection(.enabled)
                }
            }
            
            HStack {
                Spacer()
                RefreshButton(isBusy: self.$isBusy, action: getNewQuotes)
                Spacer()
            }
        }
        .listStyle(.plain)
        .padding()
    }
    
    private func getNewQuotes() {
        if isBusy {
            return
        }
        
        isBusy = true
        getTVShowQuote(
            from: self.selectedTvShow,
            count: self.count,
            keepShort: self.shortQuote
        ) { responses, error in
            self.error = error?.localizedDescription
            
            self.responses = responses
            UserDefaults.saveNewTVShowQuotes(responses)
            
            self.isBusy = false
        }
    }
}

#Preview {
    TVShowQuotesView()
}
