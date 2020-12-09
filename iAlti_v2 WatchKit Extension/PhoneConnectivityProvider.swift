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
    
    func send(dict: Dictionary<String, Any>) {
        debugPrint("Sending dictionary to iPhone: ", dict)
        let logTransfer = WCSession.default.transferUserInfo(dict)
        debugPrint("Callback:", logTransfer)
    }
}
