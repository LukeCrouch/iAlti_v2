//
//  ViewModelPhone.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import Foundation
import WatchConnectivity
import CoreData

final class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    private let persistentContainer: NSPersistentContainer
    private let session: WCSession
    
    init(session: WCSession = .default, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.session = session
        super.init()
        session.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Error activating WCSession: \(error?.localizedDescription ?? "none")")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated.")
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
