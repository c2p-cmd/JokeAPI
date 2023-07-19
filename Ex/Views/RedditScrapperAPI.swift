//
//  RedditMemeAPI.swift
//  Ex
//
//  Created by Sharan Thakur on 18/07/23.
//

import SwiftUI

struct RedditScrapperView: View {
    @AppStorage("reddit_meme") private var redditMemeResponse: RedditMemeResponse = UserDefaults.savedRedditAnimalResponse
    @AppStorage("chosen_reddit_meme") private var subreddit: String = allAnimalSubreddits[0]
    
    @State private var isBusy = false
    @State private var showDialog = false
    @State private var error: String?
    @State private var alertText = ""
    @State private var alertDescription = ""
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Picker(selection: self.$subreddit) {
                    ForEach(allAnimalSubreddits, id: \.hashValue) {
                        Text($0.capitalized)
                            .tag($0.hashValue)
                    }
                } label: {
                    Text("Chosen Subreddit")
                        .font(.system(.body, design: .rounded, weight: .semibold))
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
                    .saveImageContextMenu { (didSucess: Bool, error: String) in
                        if didSucess {
                            self.alertText = "Success!"
                            self.alertDescription = "This image has been saved in your gallery!"
                        } else {
                            self.alertText = "Failed"
                            self.alertDescription = "This image couldn't be saved in your gallery. \(error)"
                        }
                        showDialog = didSucess
                    }
                    .frame(height: 500)
            } else {
                AsyncImage(url: URL(string: redditMemeResponse.url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .saveImageContextMenu { (didSucess: Bool, error: String) in
                            if didSucess {
                                self.alertText = "Success!"
                                self.alertDescription = "This image has been saved in your gallery!"
                            } else {
                                self.alertText = "Failed"
                                self.alertDescription = "This image couldn't be saved in your gallery. \(error)"
                            }
                            showDialog = didSucess
                        }
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
        .alert(self.alertText, isPresented: self.$showDialog) {
            Button(role: .cancel) {
                self.showDialog = false
            } label: {
                Text("Okay")
            }
        } message: {
            Text(self.alertDescription)
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
