//
//  ViewModelPhone.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import Foundation
import WatchConnectivity
import CoreLocation.CLLocation

final class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        guard WCSession.isSupported() else {
            debugPrint("WCSession not supported!")
            super.init()
            return
        }
        debugPrint("Activating WCSession.")
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error == nil {
            debugPrint("Activated WCSession.")
        } else { debugPrint("Activated WCSession with Error: \(error?.localizedDescription ?? "none")") }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("WCSession became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("WCSession deactivated.")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        debugPrint("Received data from Watch:", (userInfo["timestamps"] as! [String])[0], "Size: ", (userInfo["timestamps"] as! [String]).count)
        PersistenceManager.shared.receiveFromWatch(userInfo: userInfo)
    }
}
