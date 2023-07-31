//
//  Storage.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI

class JokeViews: ObservableObject {
    static let shared = JokeViews()
    
    private init() {
        self.getNewJoke()
    }
    
    @Published var savedJoke = UserDefaults.savedJoke
    var isBusy = false
    
    func views() -> [some View] {
        return [
            GenericWidgetView(backgroundImage: {
                Image("FUNNY 1")
                    .resizable()
            }, textView: {
                Text(self.savedJoke)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            })
        ].map {
            $0.onTapGesture {
                self.getNewJoke()
            }
        }
    }
    
    private func getNewJoke() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        Task {
            let result = await getRandomJoke(of: [], type: .twopart, safeMode: true)
            
            switch result {
            case .success(let newJoke):
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewJoke(newJoke)
                        self.savedJoke = newJoke
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

class QuoteViews: ObservableObject {
    static let shared = QuoteViews()
    
    private init() {
        self.getNewQuote()
    }
    
    @Published var savedQuote = UserDefaults.savedQuote
    var isBusy = false
    
    func views() -> [some View] {
        let text = VStack {
            Text(savedQuote.content)
                .multilineTextAlignment(.leading)
                .font(.custom("Chalkduster", size: 18))
            
            HStack {
                Spacer()
                Text("-\(savedQuote.author)")
                    .multilineTextAlignment(.trailing)
                    .font(.custom("Chalkduster", size: 11.5))
                
            }
        }.foregroundStyle(.white)
        
        return [
            GenericWidgetView(backgroundImage: {
                Image("BLACKBOARD2")
                    .resizable()
            }, textView: {
                text
            }),
            
            GenericWidgetView(backgroundImage: {
                Image("BLACKBOARD")
                    .resizable()
            }, textView: {
                text
            })
        ].map {
            $0.onTapGesture {
                self.getNewQuote()
            }
        }
    }
    
    private func getNewQuote() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        Task {
            let result = await getRandomQuote()
            
            switch result {
            case .success(let newQuote):
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewQuote(newQuote)
                        self.savedQuote = newQuote
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

class SpeedTestViews: ObservableObject {
    static let shared = SpeedTestViews()
    
    private init() {
        let (ping, speed) = UserDefaults.savedSpeedWithPing
        self.pingMS = ping
        self.savedSpeed = speed
        self.getNewSpeed()
    }
    
    @Published var savedSpeed: Speed
    @Published var pingMS: Int
    var isBusy = false
    
    func views() -> [some View] {
        [
            GenericWidgetView(backgroundImage: {
                Image("Speed WIDGETS SCREEN2")
                    .resizable()
            }, textView: {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Ping: \(pingMS)")
                            .font(.custom("DS-Digital", size: 21))
                        
                        Text("Download Speed")
                            .font(.custom("DS-Digital", size: 16.5))
                        
                        Text(self.savedSpeed.widgetDescription())
                            .font(.custom("DS-Digital", size: 30))
                        
                        Text(Date().formatted(date: .omitted, time: .shortened))
                            .font(.custom("DS-Digital", size: 19))
                    }
                }
                .padding(.trailing, 25)
                .bold()
                .multilineTextAlignment(.trailing)
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            })
        ].map {
            $0.onTapGesture {
                self.getNewSpeed()
            }
        }
    }
    
    private func getNewSpeed() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        Task {
            let result = await DownloadService.shared.testWithPing(for: url, in: 60)
            
            switch result {
            case .success(let (ping, speed)):
                DispatchQueue.main.async {
                    withAnimation {
                        self.pingMS = ping
                        self.savedSpeed = speed
                        UserDefaults.saveNewSpeedWithPing(ping: ping, speed: speed)
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

class FlirtyLineViews: ObservableObject {
    static let shared = FlirtyLineViews()
    
    private init() {
        savedFlirtyLine = UserDefaults.savedFlirtyLine
        self.getNewFlirtyLine()
    }
    
    @Published var savedFlirtyLine: String
    var isBusy = false
    
    func views() -> [some View] {
        [
            GenericWidgetView(backgroundImage: {
                Image("wp3515553")
                    .resizable()
                    .offset(y: 50)
                    .opacity(0.33)
                    .rotationEffect(.degrees(180))
                    .background(.pink)
            }, textView: {
                Text(self.savedFlirtyLine)
                    .font(.custom("SavoyeLetPlain", size: 30))
                    .shadow(radius: 1.0)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            })
        ].map {
            $0.onTapGesture {
                self.getNewFlirtyLine()
            }
        }
    }
    
    private func getNewFlirtyLine() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        getPickupLine { res in
            switch res {
            case .success(let newLine):
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewFlirtyLine(newLine)
                        self.savedFlirtyLine = newLine
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

class NASApodView: ObservableObject {
    static let shared = NASApodView()
    
    private init() {
        var savedApod = UserDefaults.savedApod
        savedApod.uiImage = UIImage(named: "M31WideField_Ziegenbalg_960")
        self.apod = savedApod
        self.getApod()
    }
    
    @Published var apod: ApodResponse
    var isBusy = false
    
    func views() -> [some View] {
        let apodImage = AsyncImage(url: URL(string: apod.url)) {
            $0.resizable()
        } placeholder: {
            Image("M31WideField_Ziegenbalg_960")
                .resizable()
        }
        
        let text = VStack {
            Spacer()
            Text(self.apod.title)
                .foregroundStyle(.white)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .background(LinearGradient(colors: [.black, .black.opacity(0.5), .black.opacity(0.1)], startPoint: .bottom, endPoint: .top))
        }
        
        return [
            GenericWidgetView(backgroundImage: {
                apodImage
            }, textView: {
                text
            }, widgetFamily: .systemSmall),
            
            GenericWidgetView(backgroundImage: {
                apodImage
            }, textView: {
                text
            }, widgetFamily: .systemMedium),
            
            GenericWidgetView(backgroundImage: {
                apodImage
            }, textView: {
                text
            }, widgetFamily: .systemLarge)
        ].map {
            $0.onTapGesture {
                self.getApod()
            }
        }
    }
    
    private func getApod() {
        Task {
            let res = await getNASAApod()
            
            switch res {
            case .success(let newResponse):
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewNASAApod(newResponse)
                        self.apod = newResponse
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}
