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
    @Published var showPrivacyAlert = false
    
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
            case .notDetermined:
                debugPrint("CM: Awaiting user prompt...")
                showPrivacyAlert = true
            case .restricted: // Handle system-wide restriction
                debugPrint("CM Authorization restricted!")
                showPrivacyAlert = true
            case .denied: // Handle user denied state
                debugPrint("CM Authorization denied!")
                showPrivacyAlert = true
            case .authorized: // Ready to go!
                debugPrint("CM Authorized!")
            @unknown default:
                debugPrint("Unknown CM Authorization Status!")
                showPrivacyAlert = true
            }
            self.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
                if let trueData = data {
                    self.timestamp = trueData.timestamp
                    self.pressure = trueData.pressure.doubleValue * 10
                    self.barometricAltitude =  8400 * (UserSettings.shared.qnh - Altimeter.shared.pressure) / UserSettings.shared.qnh
                    self.speedVertical = (trueData.relativeAltitude.doubleValue - Altimeter.shared.relativeAltitude) / (trueData.timestamp - lastTimestamp)
                    self.glideRatio = (LocationManager.shared.lastLocation?.speed ?? 0) / (-1 * Altimeter.shared.speedVertical)
                    self.relativeAltitude = trueData.relativeAltitude.doubleValue
                    
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
