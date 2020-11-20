//
//  PhoneConnectivityProvider.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 20.11.20.
//

import Foundation
import WatchConnectivity

final class PhoneConnectivityProvider: NSObject, WCSessionDelegate {
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Error activating WCSession: \(error?.localizedDescription ?? "none")")
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession not supported!")
            return
        }
        print("Activating WCSession.")
        session.activate()
    }
}
