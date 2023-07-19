//
//  RedditMemeView.swift
//  Ex
//
//  Created by Sharan Thakur on 19/07/23.
//

import SwiftUI

struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    public var image: Image
    public var caption: String
}

struct MemeGenerator: View {
    @State private var templates: [MemeTemplate] = [.defaultMemeTemplate]
    @State private var selectedTemplate: MemeTemplate = .defaultMemeTemplate
    
    @State private var meme: UIImage?
    
    @State private var textFieldText: String = ""
    @State private var error: String?
    @State private var isBusy = false
    
    var body: some View {
        List {
            if let error {
                Text(error)
            }
            
            // Meme Template Picker
            if templates.isNotEmpty {
                Picker("Choose a template", selection: self.$selectedTemplate) {
                    ForEach(templates, id: \.self) { template in
                        Text(template.name)
                            .tag(template.hashValue)
                    }
                }
            }
            
            // Lines
            TextField("Meme Text", text: self.$textFieldText, axis: .vertical)
                .lineLimit(selectedTemplate.lines, reservesSpace: true)
            
            if let meme = meme {
                Section {
                    Image(uiImage: meme)
                        .resizable()
                        .scaledToFit()
                        .saveImageContextMenu()
                        .frame(height: 300)
                } header: {
                    Text("Generated Meme!")
                } footer: {
                    Text("Hold on the image to save in your gallery!")
                }
                
                let photo = Photo(image: Image(uiImage: meme), caption: "Check this meme")
                
                ShareLink(
                    item: photo,
                    subject: Text("Cool Photo"),
                    message: Text("Check it out!"),
                    preview: SharePreview(
                        photo.caption,
                        image: photo.image
                    )
                )
            }
            
            
            // Example
            Section {
                AsyncImage(url: URL(string: selectedTemplate.example.url)) { image in
                    image
                        .resizable()
                        .saveImageContextMenu()
                        .frame(height: 300)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                        .progressViewStyle(.circular)
                }
                .scaledToFit()
            } header: {
                Text("Example")
            } footer: {
                VStack {
                    ForEach(selectedTemplate.example.text, id: \.hashValue) {
                        Text($0)
                    }
                }
            }
            .multilineTextAlignment(.center)
            
            HStack {
                Spacer()
                Button("Generate!") {
                    generateMeme()
                }
                .buttonStyle(.bordered)
                Spacer()
            }
        }
        .listStyle(.plain)
        .onAppear {
            UIImage.loadImage(forKey: "saved_meme") { newImage in
                if newImage == UIImage(systemName: "exclamationmark.triangle.fill")! {
                    return
                }
                self.meme = newImage
            }
            getTemplates()
        }
    }
    
    func generateMeme() {
        getMeme(
            id: selectedTemplate.id,
            text: textFieldText.components(separatedBy: "\n"),
            completion: { res in
                switch res {
                case .success(let newImage):
                    self.error = nil
                    self.meme = newImage
                    newImage.saveImage(forKey: "saved_meme")
                    break
                case .failure(let err):
                    self.error = err.localizedDescription
                    break
                }
            }
        )
    }
    
    func getTemplates() {
        Task {
            isBusy = true
            
            let result = await getMemeTemplates()
            
            switch result {
            case .success(let memeTemplates):
                self.error = nil
                self.templates = memeTemplates
                self.selectedTemplate = memeTemplates[0]
                break
            case .failure(let error):
                self.error = error.localizedDescription
                break
            }
            
            isBusy = false
        }
    }
}

struct MemeGenView_Previews: PreviewProvider {
    static var previews: some View {
        MemeGenerator()
    }
}
