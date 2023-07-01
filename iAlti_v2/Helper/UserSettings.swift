//
//  UserSettings.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import MapKit

final class UserSettings: ObservableObject {
    static var shared = UserSettings()
    
    let userDefaults = UserDefaults.standard
    
    @Published var colorSelection: Int { didSet { userDefaults.set(colorSelection, forKey: "colorSelection") } }
    
    @Published var colors: Array<Color> { didSet { userDefaults.set(colors, forKey: "colors") } }

    @Published var qnh: Double { didSet { userDefaults.set(qnh, forKey: "qnh") } }
    @Published var qnhImperial: Double { didSet { userDefaults.set(qnh, forKey: "qnhImperial") } }
    
    @Published var offset: Double { didSet { userDefaults.set(offset, forKey: "offset") } }
    @Published var offsetImperial: Double { didSet { userDefaults.set(offset, forKey: "offsetImperial") } }
    
    @Published var pilot: String { didSet { userDefaults.set(pilot, forKey: "pilot") } }
    
    @Published var glider: String { didSet { userDefaults.set(glider, forKey: "glider") } }
    
    @Published var mapTrackingMode: Bool { didSet { userDefaults.set(mapTrackingMode, forKey: "mapTrackingMode") } }
    
    @Published var unitSelection: Int{ didSet{ userDefaults.set(unitSelection, forKey: "unitSelection") } }
    
    // MARK: Init
    init() {
        self.colorSelection = userDefaults.object(forKey: "colorSelection") as? Int ?? 3
        self.qnh = userDefaults.object(forKey: "qnh") as? Double ?? 1013.25
        self.qnhImperial = userDefaults.object(forKey: "qnhImperial") as? Double ?? 1013.25 * 2.0885434
        self.offset = userDefaults.object(forKey: "offset") as? Double ?? 0
        self.offsetImperial = userDefaults.object(forKey: "offsetImperial") as? Double ?? 0
        self.colors = userDefaults.object(forKey: "colors") as? Array ?? [Color.green, Color.white, Color.red, Color.blue, Color.orange, Color.yellow, Color.pink, Color.purple, Color.black]
        self.pilot = userDefaults.object(forKey: "pilot") as? String ?? "Jerry"
        self.glider = userDefaults.object(forKey: "glider") as? String ?? "Favorite Glider"
        self.mapTrackingMode = userDefaults.object(forKey: "mapTrackingMode") as? Bool ?? false
        self.unitSelection = userDefaults.object(forKey: "unitSelection") as? Int ?? 0
    }
}
