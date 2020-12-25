//
//  PhoneConnectivityProvider.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 20.11.20.
//

import Foundation
import WatchConnectivity

class PhoneConnectivityProvider: NSObject, WCSessionDelegate {
    var session: WCSession
    
    init(session: WCSession = .default) {
        debugPrint("Activating WCSession.")
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("Activated WCSession with Error: \(error?.localizedDescription ?? "none")")
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if error == nil {
            debugPrint("Finished transferring Log to iPhone.", userInfoTransfer)
        }
    }
    
    func send(duration: Double) {
        var logDict: Dictionary = [String: Any]()
        
        if LocationManager.shared.altitudeArray.count > 0 {
            let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                return formatter
            }()
            
            var longitude: [Double] = []
            var latitude: [Double] = []
            var accuracyHorizontal: [Double] = []
            var accuracyVertical: [Double] = []
            var accuracySpeed: [Double] = []
            var speed: [Double] = []
            var timestamps: [String] = []
            var altitudeGPS: [Double] = []
            var course: [Double] = []
            
            for loc in LocationManager.shared.locationArray {
                longitude.append(loc.coordinate.longitude)
                latitude.append(loc.coordinate.latitude)
                timestamps.append(dateFormatter.string(from: loc.timestamp))
                accuracyHorizontal.append(loc.horizontalAccuracy)
                accuracyVertical.append(loc.verticalAccuracy)
                accuracySpeed.append(loc.speedAccuracy)
                speed.append(loc.speed)
                altitudeGPS.append(loc.altitude)
                course.append(loc.course)
            }
            logDict["longitude"] = longitude
            logDict["latitude"] = latitude
            logDict["timestamps"] = timestamps
            logDict["accuracyHorizontal"] = accuracyHorizontal
            logDict["accuracyVertical"] = accuracyVertical
            logDict["accuracySpeed"] = accuracySpeed
            logDict["speedHorizontal"] = speed
            logDict["altitudeGPS"] = altitudeGPS
            logDict["duration"] = duration
            logDict["course"] = course
            logDict["speedVertical"] = LocationManager.shared.speedVerticalArray
            logDict["altitudeBarometer"] = LocationManager.shared.altitudeArray
            logDict["glider"] = ""
            logDict["pilot"] = "Jerry"
            
            debugPrint("Sending dictionary to iPhone with Size: ", LocationManager.shared.locationArray.count)
            let logTransfer = WCSession.default.transferUserInfo(logDict)
            debugPrint("Callback:", logTransfer)
        } else { debugPrint("Dropped Log because it is empty.") }
    }
}
