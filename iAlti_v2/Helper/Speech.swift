//
//  Speech.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.03.21.
//

import Foundation
import AVFoundation

// voiceOutputs = ["Off", "Glide Ratio", "Speed vertical", "Speed horizontal", "Altitude", "Variometer"]
public func voiceOutput(text: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice.init(identifier: UserSettings.shared.voiceLanguages[UserSettings.shared.voiceLanguageSelection]["identifier"] ?? NSLocale.current.identifier)
    synthesizer.speak(utterance)
    
    print("Voice Synth Timestamps: ", Date(), LocationManager.shared.lastLocation?.timestamp ?? 0)
    
    //let waitSeconds = 1
    //usleep(UInt32(waitSeconds * 1000000))
}

public func prepareVoiceList() {
    var list: [Dictionary<String, String>] = []
    for voice in AVSpeechSynthesisVoice.speechVoices() {
        let language = NSLocale.init(localeIdentifier: Locale.current.languageCode!)
        
        let languageName = language.displayName(forKey: NSLocale.Key.identifier, value: voice.language) ?? ""
        
        list.append(["languageName": languageName, "languageCode": voice.language, "voiceName": voice.name, "identifier": voice.identifier])
    }
    UserSettings.shared.voiceLanguages = list
}
