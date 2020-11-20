//
//  Location.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import CoreLocation
import Combine
import CoreMotion
import SwiftUI

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
    
    @Published var locationArray = [CLLocation]() {
        willSet {
            objectWillChange.send()
        }
    }
    
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
        NotificationCenter.default.post(name: .didReceiveLocation, object: nil)
        locationArray.append(lastLocation ?? CLLocation())
        print("Location Array size: \(locationArray.count)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func start() {
        switch LocationManager.shared.locationStatus {
        case .notDetermined:
            print("CL: Awaiting user prompt...")
        //fatalError("Awaiting CL user prompt...")
        case .restricted:
            fatalError("CL Authorization restricted!")
        case .denied:
            fatalError("CL Authorization denied!")
        case .authorizedAlways:
            print("CL Authorized!")
        case .authorizedWhenInUse:
            print("CL Authorized when in use!")
        case .none:
            print("CL Authorization None!")
        @unknown default:
            fatalError("Unknown CL Authorization Status!")
        }
        locationManager.startUpdatingLocation()
    }
}
