//
//  UserSettings.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI

final class UserSettings: ObservableObject {
    static var shared = UserSettings()
    
    let userDefaults = UserDefaults.standard
    
    @Published var colorSelection: Int {
        didSet { userDefaults.set(colorSelection, forKey: "colorSelection") }
    }
    
    @Published var colors: Array<Color> {
        didSet { userDefaults.set(colors, forKey: "colors") }
    }
    
    @Published var voiceOutputSelection: Int {
        didSet { userDefaults.set(voiceOutputSelection, forKey: "voiceOutputSelection") }
    }
    
    @Published var voiceLanguageSelection: Int {
        didSet { userDefaults.set(voiceLanguageSelection, forKey: "voiceLanguageSelection") }
    }
    
    @Published var voiceLanguages: [Dictionary<String, String>] {
        didSet { userDefaults.set(voiceLanguages, forKey: "voiceLanguages") }
    }
    
    @Published var qnh: Double {
        didSet { userDefaults.set(qnh, forKey: "qnh") }
    }
    
    @Published var offset: Double {
        didSet { userDefaults.set(offset, forKey: "offset") }
    }
    
    @Published var pilot: String {
        didSet { userDefaults.set(pilot, forKey: "pilot") }
    }
    
    @Published var glider: String {
        didSet { userDefaults.set(glider, forKey: "glider") }
    }
    // MARK: Init
    init() {
        self.colorSelection = userDefaults.object(forKey: "colorSelection") as? Int ?? 3
        self.qnh = userDefaults.object(forKey: "qnh") as? Double ?? 1013.25
        self.offset = userDefaults.object(forKey: "offset") as? Double ?? 0
        self.colors = userDefaults.object(forKey: "colors") as? Array ?? [Color.green, Color.white, Color.red, Color.blue, Color.orange, Color.yellow, Color.pink, Color.purple, Color.black]
        self.pilot = userDefaults.object(forKey: "pilot") as? String ?? "Jerry"
        self.glider = userDefaults.object(forKey: "glider") as? String ?? ""
        self.voiceLanguageSelection = userDefaults.object(forKey: "voiceLanguageSelection") as? Int ?? 10
        self.voiceOutputSelection = userDefaults.object(forKey: "voiceOutputSelection") as? Int ?? 0
        self.voiceLanguages = userDefaults.object(forKey: "voiceLanguages") as? [Dictionary<String, String>] ?? []
    }
}
