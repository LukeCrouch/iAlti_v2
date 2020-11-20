//
//  UserSettings.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 17.11.20.
//

import SwiftUI

final class UserSettings: ObservableObject {
    
    @Published var colorSelection: Int {
        didSet {
            UserDefaults.standard.set(colorSelection, forKey: "colorSelection")
        }
    }
    
    @Published var qnh: Double {
        didSet {
            UserDefaults.standard.set(qnh, forKey: "qnh")
        }
    }
    
    @Published var offset: Double {
        didSet {
            UserDefaults.standard.set(offset, forKey: "offset")
        }
    }
    
    @Published var colors: Array<Color> {
        didSet {
            UserDefaults.standard.set(colors, forKey: "colors")
        }
    }
    
    init() {
        self.colorSelection = UserDefaults.standard.object(forKey: "colorSelection") as? Int ?? 0
        self.qnh = UserDefaults.standard.object(forKey: "qnh") as? Double ?? 1013.25
        self.offset = UserDefaults.standard.object(forKey: "offset") as? Double ?? 0
        self.colors = UserDefaults.standard.object(forKey: "colors") as? Array ?? [Color.green, Color.white, Color.red, Color.blue, Color.orange, Color.yellow, Color.pink, Color.purple, Color.black]
    }
}
