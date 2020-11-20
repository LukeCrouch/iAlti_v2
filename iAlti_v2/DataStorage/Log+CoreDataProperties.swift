//
//  Log+CoreDataProperties.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//
//

import Foundation
import CoreData

extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var date: Date
    @NSManaged public var flightTime: Double
    @NSManaged public var glider: String
    @NSManaged public var pilot: String
    @NSManaged public var takeoff: String
    @NSManaged public var maxAltitude: Double
    @NSManaged public var speedAvg: Double
    @NSManaged public var distance: Double

}

extension Log : Identifiable {

}
