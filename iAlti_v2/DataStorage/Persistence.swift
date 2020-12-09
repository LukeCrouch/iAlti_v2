//
//  Persistence.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreData

class PersistenceManager {
    static var shared = PersistenceManager()
    
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
    
    func receiveFromWatch(userInfo: [String : Any]) {
        let newLog = Log(context: context)
        
        Globals.shared.geocodedLocation = "Unknown"
        
        debugPrint("Saving New Log from Watch.")
        newLog.date = userInfo["date"] as! Date
        newLog.glider = UserSettings.shared.glider
        newLog.pilot = UserSettings.shared.pilot
        newLog.flightTime = userInfo["duration"] as! Double
        newLog.latitude = userInfo["latitude"] as! [Double]
        newLog.longitude = userInfo["longitude"] as! [Double]
        newLog.altitude = userInfo["altitude"] as! [Double]
        newLog.speed = userInfo["speed"] as! [Double]
        newLog.glideRatio = userInfo["glideRatio"] as! [Double]
        newLog.accuracy = userInfo["accuracy"] as! [Double]
        
        geocode(location: CLLocation(latitude: newLog.latitude[0], longitude: newLog.longitude[0]))
        newLog.maxAltitude = newLog.altitude.max() ?? 0
        newLog.distance = 0
        newLog.speedAvg = 0 // distance / duration
        
        let timer = Date()
        while true {
            if Globals.shared.geocodedLocation != "Unknown" {
                newLog.takeOff = Globals.shared.geocodedLocation
                do {
                    try context.save()
                    debugPrint("Saved Log with \(newLog.altitude.count) entries.")
                } catch {
                    debugPrint("Error Saving to persistence")
                }
                break
            }
            if (DateInterval(start: timer, end: Date()).duration > 20) {
                break
            }
            usleep(10000) // microseconds
        }
    }
}
