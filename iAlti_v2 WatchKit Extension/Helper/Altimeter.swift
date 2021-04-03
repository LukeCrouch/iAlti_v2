//
//  Altimeter.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 14.12.20.
//

import Foundation
import CoreMotion
import Combine

class Altimeter: CMAltimeter, ObservableObject {
    static let shared = Altimeter()
    
    @Published var relativeAltitude: Double = 0
    @Published var isAltimeterStarted = false
    @Published var speedVertical: Double = 0
    @Published var barometricAltitude: Double = 0
    @Published var pressure: Double = 0
    @Published var glideRatio: Double = 0
    @Published var timestamp: Double = 0
    
    func setOffset() {
        UserSettings.shared.offset = 8400 * (UserSettings.shared.qnh - Altimeter.shared.pressure) / UserSettings.shared.qnh
    }
    
    func stop() {
        self.stopRelativeAltitudeUpdates()
        self.isAltimeterStarted = false
    }
    
    func start() {
        var lastTimestamp: Double = 0
        if Altimeter.isRelativeAltitudeAvailable() {
            switch Altimeter.authorizationStatus() {
            case .notDetermined: // Handle state before user prompt
                debugPrint("CM: Awaiting user prompt...")
            //fatalError("Awaiting CM user prompt...")
            case .restricted: // Handle system-wide restriction
                fatalError("CM Authorization restricted!")
            case .denied: // Handle user denied state
                fatalError("CM Authorization denied!")
            case .authorized: // Ready to go!
                debugPrint("CM Authorized!")
            @unknown default:
                fatalError("Unknown CM Authorization Status!")
            }
            self.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
                if let trueData = data {
                    self.timestamp = trueData.timestamp
                    self.pressure = trueData.pressure.doubleValue * 10
                    self.barometricAltitude =  8400 * (UserSettings.shared.qnh - Altimeter.shared.pressure) / UserSettings.shared.qnh
                    self.speedVertical = (trueData.relativeAltitude.doubleValue - Altimeter.shared.relativeAltitude) / (trueData.timestamp - lastTimestamp)
                    self.glideRatio = (LocationManager.shared.lastLocation?.speed ?? 0) / (-1 * Altimeter.shared.speedVertical)
                    self.relativeAltitude = trueData.relativeAltitude.doubleValue
                    
                    var text = ""
                    if UserSettings.shared.audioSelection == 1 {
                        text = String(format: "%.01f", self.glideRatio)
                    } else if UserSettings.shared.audioSelection == 2 {
                        text = String(format: "%.01f", self.speedVertical)
                    } else if UserSettings.shared.audioSelection == 5 {
                        
                    }
                    voiceOutput(text: text)
                    
                    lastTimestamp = trueData.timestamp
                } else {
                    debugPrint("Error starting relative Altitude Updates: \(error?.localizedDescription ?? "Unknown Error")")
                }
            }
        }
        self.isAltimeterStarted = true
        UserSettings.shared.offset = 0
    }
}
