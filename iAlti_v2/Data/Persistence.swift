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
    
    func saveLog(duration: Double) {
        if LocationManager.shared.altitudeArray.count == 0 {
            debugPrint("Dropping Log because it is empty.")
        } else {
            debugPrint("Saving Log")
            let newLog = Log(context: context)
            newLog.date = Date()
            newLog.glider = UserSettings.shared.glider
            newLog.pilot = UserSettings.shared.pilot
            newLog.flightTime = duration
            newLog.takeOff = LocationManager.shared.geocodedLocation
            newLog.latitude = LocationManager.shared.latitudeArray
            newLog.longitude = LocationManager.shared.longitudeArray
            newLog.altitude = LocationManager.shared.altitudeArray
            newLog.speedHorizontal = LocationManager.shared.speedHorizontalArray
            newLog.glideRatio = LocationManager.shared.glideRatioArray
            newLog.accuracy = LocationManager.shared.accuracyArray
            newLog.distance = LocationManager.shared.distance
            newLog.speedVertical = LocationManager.shared.speedVerticalArray
            do {
                try context.save()
            } catch{
                debugPrint("Error Saving to persistence")
            }
            debugPrint("Saved Log with \(newLog.altitude.count) entries.")
            LocationManager.shared.resetArrays()
        }
    }
    
    func removeLog(log: Log) {
        debugPrint("Deleting single Log")
        context.delete(log)
    }
    
    func receiveFromWatch(userInfo: [String : Any]) {
        let newLog = Log(context: context)
        
        LocationManager.shared.geocodedLocation = "Unknown"
        
        debugPrint("Saving New Log from Watch.")
        newLog.date = userInfo["date"] as! Date
        newLog.glider = UserSettings.shared.glider
        newLog.pilot = UserSettings.shared.pilot
        newLog.distance = userInfo["distance"] as! Double
        newLog.flightTime = userInfo["duration"] as! Double
        newLog.latitude = userInfo["latitude"] as! [Double]
        newLog.longitude = userInfo["longitude"] as! [Double]
        newLog.altitude = userInfo["altitude"] as! [Double]
        newLog.speedHorizontal = userInfo["speedHorizontal"] as! [Double]
        newLog.glideRatio = userInfo["glideRatio"] as! [Double]
        newLog.accuracy = userInfo["accuracy"] as! [Double]
        newLog.speedVertical = userInfo["speedVertical"] as! [Double]
        
        geocode(location: CLLocation(latitude: newLog.latitude[0], longitude: newLog.longitude[0]))
        
        let timer = Date()
        while true {
            if LocationManager.shared.geocodedLocation != "Unknown" {
                newLog.takeOff = LocationManager.shared.geocodedLocation
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
