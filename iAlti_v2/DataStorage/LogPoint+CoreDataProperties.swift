//
//  LogPoint+CoreDataProperties.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//
//

import Foundation
import CoreData

extension LogPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogPoint> {
        return NSFetchRequest<LogPoint>(entityName: "LogPoint")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var speed: Double
    @NSManaged public var log: Log

}

extension LogPoint : Identifiable {

}
