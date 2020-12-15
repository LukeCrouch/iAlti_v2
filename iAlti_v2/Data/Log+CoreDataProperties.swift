//
//  Log+CoreDataProperties.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 24.11.20.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var date: Date
    @NSManaged public var distance: Double
    @NSManaged public var flightTime: Double
    @NSManaged public var glider: String
    @NSManaged public var pilot: String
    @NSManaged public var takeOff: String
    @NSManaged public var speedVertical: [Double]
    @NSManaged public var altitude: [Double]
    @NSManaged public var speedHorizontal: [Double]
    @NSManaged public var glideRatio: [Double]
    @NSManaged public var latitude: [Double]
    @NSManaged public var longitude: [Double]
    @NSManaged public var accuracy: [Double]

}

extension Log : Identifiable {

}
