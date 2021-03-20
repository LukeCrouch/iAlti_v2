//
//  Speech.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 20.03.21.
//

import Foundation
import AVFoundation

// voiceOutputs = ["Off", "Glide Ratio", "Speed vertical", "Speed horizontal", "Altitude", "Variometer"]
public func voiceOutput() {
    repeat {
        var text = ""
        if UserSettings.shared.voiceOutputSelection == 1 {
            text = String(format: "%.01f", Altimeter.shared.glideRatio)
        } else if UserSettings.shared.voiceOutputSelection == 2 {
            text = String(format: "%.01f", Altimeter.shared.speedVertical)
        } else if UserSettings.shared.voiceOutputSelection == 3 {
            text = String(format: "%.01f", LocationManager.shared.lastLocation?.speed ?? 0)
        } else if UserSettings.shared.voiceOutputSelection == 4 {
            text = String(format: "%.01f", Altimeter.shared.barometricAltitude)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice.init(identifier: UserSettings.shared.voiceLanguages[UserSettings.shared.voiceLanguageSelection]["identifier"] ?? NSLocale.current.identifier)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    } while LocationManager.shared.didLand == false && LocationManager.shared.didTakeOff == true
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
