//
//  RedditMemeAPI.swift
//  Ex
//
//  Created by Sharan Thakur on 18/07/23.
//

import SwiftUI

struct RedditScrapperView: View {
    @AppStorage("reddit_meme") private var redditMemeResponse: RedditMemeResponse = UserDefaults.savedRedditMemeResponse
    
    @State private var isBusy = false
    @State private var showFullScreen = false
    @State private var error: String?
    @State private var subreddit = "cute"
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Picker(selection: self.$subreddit) {
                    ForEach(allCases, id: \.self) {
                        Text($0.capitalized)
                            .tag($0.hashValue)
                    }
                } label: {
                    Text("Joke Type")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .pickerStyle(.menu)
            }
            
            HStack(alignment: .top) {
                if redditMemeResponse.nsfw {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                
                Text(redditMemeResponse.title)
                    .font(.system(.title2, design: .rounded, weight: .semibold))
            }
            
            if let error {
                Text(error)
            }
            
            if let image = redditMemeResponse.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .saveImageContextMenu()
                    .frame(height: 500)
            } else {
                AsyncImage(url: URL(string: redditMemeResponse.url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .saveImageContextMenu()
                        .frame(height: 500)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 100, height: 100)
                }
            }
            
            RefreshButton(isBusy: self.$isBusy, action: getNewImage)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.showFullScreen = true
                } label: {
                    Label("Settings", systemImage: "gear.circle")
                }
            }
        }
        .fullScreenCover(isPresented: self.$showFullScreen) {
            CustomImageView {
                self.showFullScreen = false
            }
        }
    }
    
    func getNewImage() {
        Task {
            isBusy = true
            
            let result = await getRedditMeme(from: subreddit)
            
            switch result {
            case .success(let newResponse):
                self.error = nil
                self.redditMemeResponse = newResponse
                break
            case .failure(let failure):
                self.error = failure.localizedDescription
                break
            }
            
            isBusy = false
        }
    }
}
