//
//  Storage.swift
//  Ex
//
//  Created by Sharan Thakur on 28/07/23.
//

import SwiftUI
import WidgetKit

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
                    .foregroundStyle(.white)
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
                .font(.custom(Bool.random() ? "Chalkduster" : "EraserDust", size: 18))
            
            HStack {
                Spacer()
                Text("-\(savedQuote.author)")
                    .multilineTextAlignment(.trailing)
                    .font(.custom(Bool.random() ? "Chalkduster" : "EraserDust", size: 11.5))
                
            }
        }.foregroundStyle(.white)
        
        return [
            GenericWidgetView(backgroundImage: {
                Image("black")
                    .resizable()
            }, textView: {
                text
            }),
            
            GenericWidgetView(backgroundImage: {
                Image("green_w_chalk")
                    .resizable()
            }, textView: {
                text
            }),
            
            GenericWidgetView(backgroundImage: {
                Image("black_w_chalk")
                    .resizable()
            }, textView: {
                text
            }),
            
            GenericWidgetView(backgroundImage: {
                Image("green")
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
        let (savedSpeed, savedDate) = UserDefaults.savedSpeedWithDate
        self.savedSpeed = savedSpeed
        self.date = savedDate
        self.getNewSpeed()
    }
    
    let id: UUID = UUID()
    
    @Published var date: Date?
    @Published var savedSpeed: Speed
    var isBusy = false
    
    var views: [some View] {
        return [
            GenericWidgetView(backgroundImage: {
                Image("SpeedTest_bluecontrast")
                    .resizable()
            }, textView: {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Download Speed")
                            .font(.custom("DS-Digital", size: 16.5))
                        
                        if date == nil {
                            Text("----")
                                .font(.custom("DS-Digital", size: 30))
                        } else {
                            Text(self.savedSpeed.widgetDescription())
                                .font(.custom("DS-Digital", size: 30))
                        }
                        
                        if let date {
                            Text(date.formatted(date: .omitted, time: .shortened))
                                .font(.custom("DS-Digital", size: 19))
                        }
                    }
                }
                .padding(.trailing, 25)
                .bold()
                .multilineTextAlignment(.trailing)
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            }),
            
            GenericWidgetView(backgroundImage: {
                Image("Speed Widget New 1")
                    .resizable()
            }, textView: {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Download Speed")
                            .font(.custom("DS-Digital", size: 16.5))
                        
                        if date == nil {
                            Text("----")
                                .font(.custom("DS-Digital", size: 30))
                        } else {
                            Text(self.savedSpeed.widgetDescription())
                                .font(.custom("DS-Digital", size: 30))
                        }
                        
                        if let date {
                            Text(date.formatted(date: .omitted, time: .shortened))
                                .font(.custom("DS-Digital", size: 19))
                        }
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
            let result = await DownloadService.shared.test(for: url, in: 60)
            
            switch result {
            case .success(let speed):
                DispatchQueue.main.async {
                    withAnimation {
                        self.savedSpeed = speed
                        self.date = .now
                        UserDefaults.saveNewSpeed(speed: speed, at: .now)
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
                Image("Flirty Coochie Coochie")
                    .resizable()
            }, textView: {
                Text(self.savedFlirtyLine)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
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
        return [
            GenericWidgetView(backgroundImage: {
                AsyncImage(url: URL(string: apod.url)) {
                    $0.resizable()
                } placeholder: {
                    Image("AuroraSnow")
                        .resizable()
                }
            }, textView: {
            }, widgetFamily: .systemLarge)
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

class FactAboutTodayView: ObservableObject, Identifiable {
    static let shared = FactAboutTodayView()
    
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
                Image("numbers_background", bundle: .main)
                    .resizable()
                    .overlay(alignment: .center) {
                        Image("grainy-opacity-80")
                            .resizable()
                            .scaledToFill()
                    }
            }, textView: {
                Text(self.funFact)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
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

class BhagvatGitaView: Identifiable {
    static let shared = BhagvatGitaView()
    
    private init() {
        self.bhagwatGitaResponse = UserDefaults.savedBhagvatGitaResponses.randomElement()!
    }
    
    let id: UUID = UUID()
    let bhagwatGitaResponse: BhagvatGitaResponse
    
    var views: [some View] {
        let brown = Color(red: 104/256, green: 63/256, blue: 17/256)
        
        let text = VStack {
            Text(bhagwatGitaResponse.englishTranslation)
                .multilineTextAlignment(.leading)
                .font(.custom("handwriting-draft_free-version", size: 15))
            
            HStack {
                Spacer()
                Text("-\(bhagwatGitaResponse.englishAuthor)")
                    .multilineTextAlignment(.trailing)
                    .font(.custom("handwriting-draft_free-version", size: 12.5))
                
            }
        }.foregroundStyle(brown)
        
        let textHindi = VStack {
            Text(bhagwatGitaResponse.hindiTranslation)
                .multilineTextAlignment(.leading)
                .font(.custom("Devanagari Sangam MN", size: 15))
            
            HStack {
                Spacer()
                Text("-\(bhagwatGitaResponse.hindiAuthor)")
                    .multilineTextAlignment(.trailing)
                    .font(.custom("handwriting-draft_free-version", size: 12.5))
            }
        }.foregroundStyle(brown)
        
        return [
            GenericWidgetView(backgroundImage: {
                Image("bhagawatGita")
                    .resizable()
            }, textView: {
                text
            }, widgetFamily: .systemMedium),
            
            GenericWidgetView(backgroundImage: {
                Image("bhagawatGita")
                    .resizable()
            }, textView: {
                textHindi
            }, widgetFamily: .systemMedium)
        ]
    }
}

class TVShowQuotesResponsesView: Identifiable, ObservableObject {
    static let shared = TVShowQuotesResponsesView()
    
    @Published var tvShowQuote: TVShowQuoteResponse
    let id: UUID = UUID()
    private var isBusy = false
    
    private init() {
        self.tvShowQuote = UserDefaults.savedTVShowQuotes.randomElement()!
        self.getNew()
    }
    
    private func myFont(size: CGFloat) -> Font {
        .custom("Arial Rounded MT Bold", size: size)
    }
    
    var views: [some View] {
        let widgetView = GenericWidgetView {
            Image("TV_Quote_BG")
                .resizable()
        } textView: {
            VStack(spacing: 10) {
                Text(tvShowQuote.text)
                    .font(myFont(size: 15))
                
                HStack {
                    Text("From: \"\(tvShowQuote.show)\"")
                    Spacer()
                    Text("-\(tvShowQuote.character)")
                }
                .font(myFont(size: 11.5))
            }
            .padding(.all, 25)
            .minimumScaleFactor(0.75)
        }
        return [
            widgetView
        ]
    }
    
    private func getNew() {
        if isBusy {
            return
        }
        
        isBusy = true
        getTVShowQuote { responses, _ in
            self.isBusy = false
            DispatchQueue.main.async {
                withAnimation {
                    self.tvShowQuote = responses.randomElement()!
                }
            }
        }
    }
}

class NextMCUFilmResponseView: Identifiable, ObservableObject {
    static let shared = NextMCUFilmResponseView()
    
    @Published var mcuFilm: NextMcuFilm
    let id: UUID = UUID()
    private var isBusy = false
    
    private init() {
        mcuFilm = ListofNextMCUFilms.getDummyData().randomElement()!
        self.getNextMCUFilm()
    }
    
    var views: [some View] {
        let views: [any View] = [
            ZStack {
                imageBG(widgetFamily: .systemLarge)
                
                VStack {
                    AsyncImage(url: URL(string: mcuFilm.posterUrl)) {
                        $0.resizable()
                    } placeholder: {
                        ProgressView()
                            .padding()
                    }
                    .scaledToFit()
                    .frame(height: self.height(widgetFamily: .systemLarge))
                    
                    Text(mcuFilm.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Text(mcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .minimumScaleFactor(0.75)
                .foregroundStyle(.white)
                .padding(.all, 15)
            }.modifier(ModifyForWidgetViewFrame(widgetFamily: .systemLarge))
                .background(.clear),
            
            ZStack {
                imageBG(widgetFamily: .systemMedium)
                
                HStack {
                    AsyncImage(url: URL(string: mcuFilm.posterUrl)) {
                        $0.resizable()
                    } placeholder: {
                        ProgressView()
                            .padding()
                    }
                    .scaledToFit()
                    .frame(height: self.height(widgetFamily: .systemMedium))
                    
                    VStack {
                        Text(mcuFilm.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        
                        Text(mcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .padding()
                }
                .minimumScaleFactor(0.75)
                .foregroundStyle(.white)
                .padding(.all, 15)
            }.modifier(ModifyForWidgetViewFrame(widgetFamily: .systemMedium))
                .background(.clear),
            
            ZStack {
                imageBG(widgetFamily: .systemSmall)
                
                VStack {
                    AsyncImage(url: URL(string: mcuFilm.posterUrl)) {
                        $0.resizable()
                    } placeholder: {
                        ProgressView()
                            .padding()
                    }
                    .scaledToFit()
                    .frame(height: self.height(widgetFamily: .systemSmall))
                    
                    Text(mcuFilm.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    Text(mcuFilm.theReleaseDate.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .minimumScaleFactor(0.75)
                .foregroundStyle(.white)
                .padding(.all, 15)
            }.modifier(ModifyForWidgetViewFrame(widgetFamily: .systemSmall))
                .background(.clear)
        ]
        
        return views.map { AnyView($0) }
    }
    
    private func imageBG(widgetFamily: WidgetFamily) -> some View {
        Image("Marvel Logo")
            .resizable()
            .scaledToFill()
            .opacity(0.25)
            .blur(radius: 8.0)
            .modifier(ModifyForWidgetViewFrame(widgetFamily: widgetFamily))
            .overlay {
                Color.red.opacity(0.1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func height(widgetFamily: WidgetFamily) -> CGFloat? {
        if widgetFamily == .systemSmall {
            return 110
        }
        
        if widgetFamily == .systemMedium {
            return 150
        }
        
        if widgetFamily == .systemLarge {
            return 300
        }
        
        return nil
    }
    
    
    private func getNextMCUFilm() {
        if isBusy {
            return
        }
        self.isBusy = true
        Ex.getNextMCUFilm { result in
            switch result {
            case .success(let newFilm):
                DispatchQueue.main.async {
                    self.mcuFilm = newFilm
                    self.isBusy = false
                }
                break
            case .failure(_):
                break
            }
        }
    }
}
