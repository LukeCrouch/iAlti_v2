//
//  Persistence.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreData

class PersistenceManager {
    
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Logs")
        container.loadPersistentStores { description, error in
            if let error = error {
                debugPrint("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
    
    init() {
        let center = NotificationCenter.default
        let notification = UIApplication.willResignActiveNotification
        
        center.addObserver(forName: notification, object: nil, queue: nil) { [weak self] _ in
            guard self != nil else { return }
            
            if PersistenceManager.persistentContainer.viewContext.hasChanges {
                do {
                    try PersistenceManager.persistentContainer.viewContext.save()
                } catch {
                    debugPrint("Error saving Changes to Persistence:", error.localizedDescription)
                }
            }
        }
    }
}
