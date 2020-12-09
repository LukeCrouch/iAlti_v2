//
//  ViewModelPhone.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI
import WatchConnectivity

final class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    
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
        debugPrint("Received data from Watch:", userInfo["date"]!, "Size: ", (userInfo["altitude"] as! [Double]).count)
        PersistenceManager.shared.receiveFromWatch(userInfo: userInfo)
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            debugPrint("WCSession not supported!")
            return
        }
        
        let session = WCSession.default
        
        debugPrint("Activating WCSession.")
        session.delegate = self
        session.activate()
    }
}
