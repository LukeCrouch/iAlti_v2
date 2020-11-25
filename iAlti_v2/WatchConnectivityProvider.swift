//
//  ViewModelPhone.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import Foundation
import WatchConnectivity
import CoreData
import CoreLocation.CLLocation

final class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("Activated WCSession with Error: \(error?.localizedDescription ?? "none")")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("WCSession became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("WCSession deactivated.")
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
