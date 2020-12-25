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

    @NSManaged public var glider: String
    @NSManaged public var pilot: String
    @NSManaged public var takeOff: String
    @NSManaged public var date: Date
    @NSManaged public var flightTime: Double
    @NSManaged public var speedVertical: [Double]
    @NSManaged public var altitudeGPS: [Double]
    @NSManaged public var altitudeBarometer: [Double]
    @NSManaged public var longitude: [Double]
    @NSManaged public var latitude: [Double]
    @NSManaged public var speedHorizontal: [Double]
    @NSManaged public var accuracyHorizontal: [Double]
    @NSManaged public var accuracyVertical: [Double]
    @NSManaged public var accuracySpeed: [Double]
    @NSManaged public var course: [Double]
    @NSManaged public var timestamps: [String]
    @NSManaged public var id: UUID
    @NSManaged public var fromWatch: Bool

}

extension Log : Identifiable {

}
