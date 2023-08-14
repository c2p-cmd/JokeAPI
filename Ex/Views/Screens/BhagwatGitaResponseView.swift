//
//  BhagwatGitaResponseView.swift
//  Ex
//
//  Created by Sharan Thakur on 14/08/23.
//

import SwiftUI

struct BhagwatGitaResponseView: View {
    @State private var bhagvadGitaResponse: BhagvatGitaResponse?
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if let bhagvadGitaResponse {
                Text(bhagvadGitaResponse.shlok)
                
                Spacer().frame(height: 10)
                
                Text(bhagvadGitaResponse.hindiTranslation)
                Text(bhagvadGitaResponse.hindiAuthor)
                
                Spacer().frame(height: 10)
                
                Text(bhagvadGitaResponse.englishTranslation)
                Text(bhagvadGitaResponse.englishAuthor)
            }
            
            Button(action: getQuote, label: {
                Text("Make Request")
            })
        }
    }
    
    private func getQuote() {
        getBhagvadGitaShloka { response, error in
            if let error {
                print(error.localizedDescription)
            }
            
            if let response {
                self.bhagvadGitaResponse = response
            }
        }
    }
}
