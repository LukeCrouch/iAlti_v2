//
//  Persistence.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreData

class PersistenceManager {
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Logs")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading persistent stores:", error.localizedDescription)
            }
        }
        return container
    }()
    
    init() {
        let center = NotificationCenter.default
        let notification = UIApplication.willResignActiveNotification
        
        center.addObserver(forName: notification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            
            if self.persistentContainer.viewContext.hasChanges {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch {
                    print("Error saving Changes to Persistence:", error.localizedDescription)
                }
            }
        }
    }
}
