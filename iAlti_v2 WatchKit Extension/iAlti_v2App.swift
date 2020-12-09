//
//  iAlti_v2App.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

class Globals: ObservableObject {
    static var shared = Globals()
    
    @Published var pressure: Double = 0
    @Published var isAltimeterStarted = false
    @Published var isLocationStarted = false
    @Published var barometricAltitude: Double = 0
    @Published var relativeAltitude: Double = 0
    @Published var speedV: Double = 0
    @Published var glideRatio: Double = 0
}

public extension String {
    var model: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }
}

@main
struct iAlti_v2App: App {
    @StateObject var globals = Globals()
    @StateObject var userSettings = UserSettings()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(globals)
                    .environmentObject(userSettings)
            }
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
