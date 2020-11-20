//
//  LogPoint+CoreDataClass.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//
//

import Foundation
import CoreData

@objc(LogPoint)
public class LogPoint: NSManagedObject {
    
}

extension LogPoint {
    
    @discardableResult
    static func create(with location: CLLocation, context: NSManagedObjectContext) -> LogPoint {
        let newLogPoint = LogPoint(context: context)
        newLogPoint.altitude = location.altitude
        newLogPoint.latitude = location.coordinate.latitude
        newLogPoint.longitude = location.coordinate.longitude
        newLogPoint.speed = max(0, location.speed)
        newLogPoint.timestamp = location.timestamp
        return newLogPoint
    }
}
