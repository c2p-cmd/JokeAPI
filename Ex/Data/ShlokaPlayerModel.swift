//
//  ShlokaPlayerModel.swift
//  Ex
//
//  Created by Sharan Thakur on 25/08/23.
//

import AVFoundation

class ShlokaPlayerModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = ShlokaPlayerModel()
    
    @Published var englishVoice: AVSpeechSynthesisVoice
    @Published var hindiVoice: AVSpeechSynthesisVoice
    @Published var synthesizer = AVSpeechSynthesizer()
    
    override init() {
        let allSpeeches = AVSpeechSynthesisVoice.speechVoices()
        self.englishVoice = allSpeeches.first(where: { $0.language.starts(with: "en") })!
        self.hindiVoice = allSpeeches.first(where: { $0.language.starts(with: "hi") })!
        super.init()
        synthesizer.delegate = self
    }
    
    func playSound(shloka: String, in language: ShlokaLanguage) async throws {
        try AVAudioSession.sharedInstance().setCategory(.playback)
        try AVAudioSession.sharedInstance().setMode(.default)
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
            return
        }
        
        let utter = AVSpeechUtterance(string: shloka)
        utter.volume = 2
        switch language {
        case .english:
            utter.voice = englishVoice
            break
        case .hindi:
            utter.voice = hindiVoice
            break
        }
        
        synthesizer.speak(utter)
    }
}
