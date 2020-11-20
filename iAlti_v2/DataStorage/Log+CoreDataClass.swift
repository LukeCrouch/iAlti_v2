//
//  Log+CoreDataClass.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//
//

import Foundation
import CoreData

@objc(Log)
public class Log: NSManagedObject {
    
    func addLogPoint(with location: CLLocation, context: NSManagedObjectContext) {
        LogPoint.create(with: location, context: context)
    }

}
