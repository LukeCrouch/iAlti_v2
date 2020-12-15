//
//  PhoneConnectivityProvider.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI
import WatchConnectivity

final class PhoneConnectivityProvider: NSObject, WCSessionDelegate {
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("Activated WCSession with Error: \(error?.localizedDescription ?? "none")")
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if error == nil {
            debugPrint("Finished transferring Log to iPhone.")
        }
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            debugPrint("WCSession not supported!")
            return
        }
        debugPrint("Activating WCSession.")
        session.activate()
    }
    
    func send(duration: Double) {
        var logDict: Dictionary = [String: Any]()
        debugPrint("Sending dictionary to iPhone: ", logDict)
        
        Altimeter.shared.stopRelativeAltitudeUpdates()
        Altimeter.shared.isAltimeterStarted = false
        LocationManager.shared.stop()
        LocationManager.shared.isLocationStarted = false
        
        if LocationManager.shared.altitudeArray.count > 0 {
            logDict["date"] = Date()
            logDict["duration"] = duration
            logDict["altitude"] = LocationManager.shared.altitudeArray
            logDict["accuracy"] = LocationManager.shared.accuracyArray
            logDict["glider"] = ""
            logDict["pilot"] = "Jerry"
            logDict["glideRatio"] = LocationManager.shared.glideRatioArray
            logDict["latitude"] = LocationManager.shared.latitudeArray
            logDict["longitude"] = LocationManager.shared.longitudeArray
            logDict["speedHorizontal"] = LocationManager.shared.speedHorizontalArray
            logDict["takeOff"] = "From Watch"
            logDict["speedVertical"] = LocationManager.shared.speedVerticalArray
        } else { debugPrint("Dropped Log because it is empty.") }
        
        let logTransfer = WCSession.default.transferUserInfo(logDict)
        debugPrint("Callback:", logTransfer)
    }
}
