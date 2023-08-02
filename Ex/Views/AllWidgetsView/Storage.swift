//
//  Storage.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI

class JokeViews: ObservableObject, Identifiable {
    static let shared = JokeViews()
    
    private init() {
        self.getNewJoke()
    }
    
    let id: UUID = UUID()
    @Published var savedJoke = UserDefaults.savedJoke
    var isBusy = false
    
    var views: [some View] {
        return [
            GenericWidgetView(backgroundImage: {
                Image("FUNNY 1")
                    .resizable()
            }, textView: {
                Text(self.savedJoke)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            })
        ]
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

class QuoteViews: ObservableObject, Identifiable {
    static let shared = QuoteViews()
    
    private init() {
        self.getNewQuote()
    }
    
    let id: UUID = UUID()
    @Published var savedQuote = UserDefaults.savedQuote
    var isBusy = false
    
    var views: [some View] {
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
        ]
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

class SpeedTestViews: ObservableObject, Identifiable {
    static let shared = SpeedTestViews()
    
    private init() {
        let (ping, speed) = UserDefaults.savedSpeedWithPing
        self.pingMS = ping
        self.savedSpeed = speed
        self.getNewSpeed()
    }
    
    let id: UUID = UUID()
    @Published var savedSpeed: Speed
    @Published var pingMS: Int
    var isBusy = false
    
    var views: [some View] {
        return [
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
        ]
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

class FlirtyLineViews: ObservableObject, Identifiable {
    static let shared = FlirtyLineViews()
    
    private init() {
        savedFlirtyLine = UserDefaults.savedFlirtyLine
        self.getNewFlirtyLine()
    }
    
    let id: UUID = UUID()
    @Published var savedFlirtyLine: String
    var isBusy = false
    
    var views: [some View] {
        return [
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
        ]
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

class NASApodView: ObservableObject, Identifiable {
    static let shared = NASApodView()
    
    private init() {
        var savedApod = UserDefaults.savedApod
        savedApod.uiImage = UIImage(named: "M31WideField_Ziegenbalg_960")
        self.apod = savedApod
        self.getApod()
    }
    
    let id: UUID = UUID()
    @Published var apod: ApodResponse
    var isBusy = false
    
    var views: [some View] {
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
            }, widgetFamily: .systemLarge),
            
            GenericWidgetView(backgroundImage: {
                apodImage
            }, textView: {
                text
            }, widgetFamily: .systemMedium),
            
            GenericWidgetView(backgroundImage: {
                apodImage
            }, textView: {
                text
            }, widgetFamily: .systemSmall)
        ]
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

class FunFactAboutTodayView: ObservableObject, Identifiable {
    static let shared = FunFactAboutTodayView()
    
    private init() {
        funFact = UserDefaults.savedFunFact
        self.getFunFact()
    }
    
    let id: UUID = UUID()
    @Published var funFact: String
    var isBusy = false
    
    var views: [some View] {
        return [
            GenericWidgetView(backgroundImage: {
                Image("IMG_6838", bundle: .main)
                    .resizable()
                    .opacity(0.6)
                    .blur(radius: 5)
            }, textView: {
                Text(self.funFact)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
            })
        ]
    }
    
    private func getFunFact() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let formattedDate = dateFormatter.string(from: Date())
        
        getFactAboutDate(formattedDate: formattedDate) { (funFact: String?, _: Error?)  in
            self.isBusy = false
            
            if let funFact {
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewFunFact(funFact)
                        self.funFact = funFact
                    }
                }
            }
        }
    }
}

class CuteAnimalView: ObservableObject, Identifiable {
    static let shared = CuteAnimalView()
    
    private init() {
        cuteAnimal = UserDefaults.savedRedditAnimalResponse
        self.getCuteAnimal()
    }
    
    let id: UUID = UUID()
    @Published var cuteAnimal: RedditMemeResponse
    var isBusy = false
    
    var views: [some View] {
        let image = AsyncImage(url: URL(string: self.cuteAnimal.url)) {
            $0.resizable()
        } placeholder: {
            if Bool.random() {
                return Image("happy_dog").resizable()
            } else {
                return Image("black_cat").resizable()
            }
        }
        
        return [
            GenericWidgetView(backgroundImage: {
                image
            }, textView: {
                
            }, widgetFamily: .systemLarge),
            
            GenericWidgetView(backgroundImage: {
                image
            }, textView: {
                
            }, widgetFamily: .systemMedium),
            
            GenericWidgetView(backgroundImage: {
                image
            }, textView: {
                
            }, widgetFamily: .systemSmall)
        ]
    }
    
    private func getCuteAnimal() {
        if self.isBusy {
            return
        }
        
        isBusy = true
        
        Task {
            let result = await getRedditMeme(from: allAnimalSubreddits.randomElement()!.string)
            
            switch result {
            case .success(let newAnimalResponse):
                DispatchQueue.main.async {
                    withAnimation {
                        UserDefaults.saveNewRedditAnimalResponse(newAnimalResponse)
                        self.cuteAnimal = newAnimalResponse
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
}

class HTTPAnimalView: Identifiable {
    static let shared = HTTPAnimalView()
    
    private init() { }
    
    let id: UUID = UUID()
    
    private let statusCodes: [Int] = [
        100, 101, 102, 103,
        200, 201, 202, 203, 204, 206, 207,
        300, 301, 302, 303, 304, 305, 307, 308,
        400, 401, 402, 403, 404, 405, 406, 407, 408, 409,
        410, 411, 412, 413, 414, 415, 416, 417, 418,
        421, 422, 423, 424, 425, 426, 428, 429, 431, 451,
        500, 501, 502, 503, 504, 505, 506, 507, 508, 510, 511
    ]
    
    private var catUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.cat/\(statusCode)")!
    }
    
    private var dogUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.dog/\(statusCode).jpg")!
    }
    
    private func image(asyncImage: Image) -> some View {
        asyncImage.resizable().offset(x: -25.0)
    }
    
    var views: [some View] {
        return [
            GenericWidgetView(backgroundImage: {
                AsyncImage(url: dogUrl, content: image, placeholder: {
                    Image("102_d").resizable()
                })
            }, textView: {
                
            }, widgetFamily: .systemLarge),
            
            GenericWidgetView(backgroundImage: {
                AsyncImage(url: dogUrl, content: image, placeholder: {
                    Image("102_d").resizable()
                })
            }, textView: {
                
            }, widgetFamily: .systemSmall),
            
            GenericWidgetView(backgroundImage: {
                AsyncImage(url: catUrl, content: image, placeholder: {
                    Image("102").resizable()
                })
            }, textView: {
                
            }, widgetFamily: .systemLarge),
            
            GenericWidgetView(backgroundImage: {
                AsyncImage(url: catUrl, content: image, placeholder: {
                    Image("102").resizable()
                })
            }, textView: {
                
            }, widgetFamily: .systemSmall)
        ]
    }
}
