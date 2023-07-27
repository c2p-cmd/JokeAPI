//
//  RedditMemeAPI.swift
//  Ex
//
//  Created by Sharan Thakur on 18/07/23.
//

import SwiftUI

struct RedditScrapperView: View {
    enum RedditViewChoice: String {
        case meme, animal
        
        var description: String {
            switch self {
            case .meme:
                "Memes"
            case .animal:
                "Animals"
            }
        }
        
        static var allCases: [Self] {
            [.animal, .meme]
        }
    }
    
    @State private var selected: RedditViewChoice = .animal
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("", selection: self.$selected) {
                    ForEach(RedditViewChoice.allCases, id: \.hashValue) {
                        Text($0.description)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                if selected == .animal {
                    RedditAnimalView()
                }
                
                if selected == .meme {
                    RedditMemeView()
                }
            }
        }
    }
}

// MEME ONLY
struct RedditMemeView: View {
    @AppStorage("reddit_memeZ") private var redditMemeResponse: RedditMemeResponse = UserDefaults.savedRedditMemeResponse
    @AppStorage("chosen_reddit_memeZ") private var subreddit: IdentifiableString = allMemeSubreddits.first!
    
    @State private var isBusy = false
    @State private var showDialog = false
    @State private var error: String?
    @State private var alertText = ""
    @State private var alertDescription = ""
    
    var body: some View {
        RedditView(
            redditMemeResponse: $redditMemeResponse,
            subreddit: $subreddit,
            allCases: Array(allMemeSubreddits),
            isBusy: $isBusy,
            showDialog: $showDialog,
            error: $error,
            alertText: $alertText,
            alertDescription: $alertDescription,
            buttonAction: getNewImage
        )
    }
    
    func getNewImage() {
        Task {
            isBusy = true
            
            let result = await getRedditMeme(from: subreddit.string)
            
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

// ANIMAL ONLY
struct RedditAnimalView: View {
    @AppStorage("reddit_meme") private var redditMemeResponse: RedditMemeResponse = UserDefaults.savedRedditAnimalResponse
    @AppStorage("chosen_reddit_meme") private var subreddit: IdentifiableString = allAnimalSubreddits.first!
    
    @State private var isBusy = false
    @State private var showDialog = false
    @State private var error: String?
    @State private var alertText = ""
    @State private var alertDescription = ""
    
    var body: some View {
        RedditView(
            redditMemeResponse: $redditMemeResponse,
            subreddit: $subreddit,
            allCases: Array(allAnimalSubreddits),
            isBusy: $isBusy,
            showDialog: $showDialog,
            error: $error,
            alertText: $alertText,
            alertDescription: $alertDescription,
            buttonAction: getNewImage
        )
    }
    
    func getNewImage() {
        Task {
            isBusy = true
            
            let result = await getRedditMeme(from: subreddit.string)
            
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

fileprivate struct RedditView: View {
    @Binding var redditMemeResponse: RedditMemeResponse
    @Binding var subreddit: IdentifiableString
    
    let allCases: [IdentifiableString]
    
    @Binding var isBusy: Bool
    @Binding var showDialog: Bool
    @Binding var error: String?
    @Binding var alertText: String
    @Binding var alertDescription: String
    
    var buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Picker(selection: self.$subreddit) {
                    ForEach(self.allCases) { element in
                        Text(element.string.capitalized)
                            .tag(element)
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
                    .frame(height: 400)
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
                        .frame(height: 400)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 100, height: 100)
                }
            }
            
            RefreshButton(isBusy: self.$isBusy, action: self.buttonAction)
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
}