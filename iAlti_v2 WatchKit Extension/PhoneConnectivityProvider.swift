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
    
    func connect() {
        guard WCSession.isSupported() else {
            debugPrint("WCSession not supported!")
            return
        }
        debugPrint("Activating WCSession.")
        session.activate()
    }
}

struct WatchCommunication {
    static let requestKey = "request"
    static let responseKey = "response"
    
    enum Content: String {
        case locations
    }
}
