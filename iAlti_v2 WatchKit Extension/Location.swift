//
//  Location.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 16.11.20.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine
import CoreMotion

final class Altimeter: CMAltimeter {
    static let shared = Altimeter()
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Purpose Key")
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
}



