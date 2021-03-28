//
//  Speech.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.03.21.
//

import Foundation
import AVFoundation

// voiceOutputs = ["Off", "Glide Ratio", "Speed vertical", "Speed horizontal", "Altitude", "Variometer"]
public func voiceOutput() {
    let synthesizer = AVSpeechSynthesizer()
    var text = ""
    
    let serialQueue = DispatchQueue(label: "swiftVario.serial.queue")
    serialQueue.async {
        repeat {
            if UserSettings.shared.audioSelection == 1 {
                text = String(format: "%.01f", Altimeter.shared.glideRatio)
            } else if UserSettings.shared.audioSelection == 2 {
                text = String(format: "%.01f", Altimeter.shared.speedVertical)
            } else if UserSettings.shared.audioSelection == 3 {
                text = String(format: "%.01f", LocationManager.shared.lastLocation?.speed ?? 0)
            } else if UserSettings.shared.audioSelection == 4 {
                text = String(format: "%.01f", Altimeter.shared.barometricAltitude)
            }
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice.init(identifier: UserSettings.shared.voiceLanguages[UserSettings.shared.voiceLanguageSelection]["identifier"] ?? NSLocale.current.identifier)
            synthesizer.speak(utterance)
            
            let waitSeconds = 1
            usleep(UInt32(waitSeconds * 1000000))
        } while LocationManager.shared.didLand == false && LocationManager.shared.didTakeOff == true
    }
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
