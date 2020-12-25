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
    
    /// Save a new Log to persistent storage with CoreData
    ///
    /// - Parameters:
    ///     - UserSettings: Pilot and Glider name
    ///     - LocationManager: Track points
    ///     - Duration: Flight time
    ///
    func saveLog(duration: Double) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        if LocationManager.shared.altitudeArray.count == 0 {
            debugPrint("Dropping Log because it is empty.")
        } else {
            debugPrint("Saving Log")
            let newLog = Log(context: context)
            newLog.id = UUID()
            newLog.fromWatch = false
            newLog.glider = UserSettings.shared.glider
            newLog.pilot = UserSettings.shared.pilot
            newLog.takeOff = LocationManager.shared.geocodedLocation
            LocationManager.shared.geocodedLocation = "Unknown"
            
            for loc in LocationManager.shared.locationArray {
                newLog.accuracyHorizontal.append(loc.horizontalAccuracy)
                newLog.accuracyVertical.append(loc.verticalAccuracy)
                newLog.accuracySpeed.append(loc.speedAccuracy)
                newLog.longitude.append(loc.coordinate.longitude)
                newLog.latitude.append(loc.coordinate.latitude)
                newLog.speedHorizontal.append(loc.speed)
                newLog.altitudeGPS.append(loc.altitude)
                newLog.course.append(loc.course)
                newLog.timestamps.append(dateFormatter.string(from: loc.timestamp))
            }
            newLog.altitudeBarometer = LocationManager.shared.altitudeArray
            newLog.speedVertical = LocationManager.shared.speedVerticalArray
            newLog.date = LocationManager.shared.locationArray.last!.timestamp
            newLog.flightTime = duration
            do {
                try context.save()
            } catch{
                debugPrint("Error Saving to persistence")
            }
            debugPrint("Saved Log with \(newLog.accuracyHorizontal.count) entries.")
            LocationManager.shared.resetArrays()
        }
    }
    
    func deleteLog(log: Log) {
        debugPrint("Deleting single Log")
        context.delete(log)
    }
    
    
    /// For conversion from optional `String` type to optional `Int` type
    ///
    /// - Parameters:
    ///     - UserSettings: Glider and Pilot Name
    ///     - userinfo: dictionary received from Apple Watch Companion App
    ///
    func receiveFromWatch(userInfo: [String : Any]) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        var timestamps: [Date] {
            var timestamps: [Date] = []
            for t in userInfo["timestamps"] as! [String] {
                timestamps.append(dateFormatter.date(from: t)!)
            }
            return timestamps
        }
        
        let newLog = Log(context: context)
        
        debugPrint("Saving New Log from Watch.")
        newLog.id = UUID()
        newLog.fromWatch = true
        newLog.glider = UserSettings.shared.glider
        newLog.pilot = UserSettings.shared.pilot
        newLog.altitudeBarometer = userInfo["altitudeBarometer"] as! [Double]
        newLog.altitudeGPS = userInfo["altitudeGPS"] as! [Double]
        newLog.speedVertical = userInfo["speedVertical"] as! [Double]
        newLog.accuracyHorizontal = userInfo["accuracyHorizontal"] as! [Double]
        newLog.accuracyVertical = userInfo["accuracyVertical"] as! [Double]
        newLog.accuracySpeed = userInfo["accuracySpeed"] as! [Double]
        newLog.longitude = userInfo["longitude"] as! [Double]
        newLog.latitude = userInfo["latitude"] as! [Double]
        newLog.timestamps = userInfo["timestamps"] as! [String]
        newLog.speedHorizontal = userInfo["speedHorizontal"] as! [Double]
        newLog.date = dateFormatter.date(from: newLog.timestamps[0])!
        newLog.flightTime = userInfo["duration"] as! Double
        newLog.course = userInfo["course"] as! [Double]
        
        LocationManager.shared.geocodedLocation = "Unknown"
        LocationManager.shared.geocode(location: CLLocation(
                                        latitude: newLog.latitude[0],
                                        longitude: newLog.longitude[0]
        ))
        
        let timer = Date()
        while true {
            if LocationManager.shared.geocodedLocation != "Unknown" {
                newLog.takeOff = LocationManager.shared.geocodedLocation
                LocationManager.shared.geocodedLocation = "Unknown"
                do {
                    try context.save()
                    debugPrint("Saved Log with \(newLog.accuracyHorizontal.count) entries.")
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
