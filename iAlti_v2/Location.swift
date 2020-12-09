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
    
    @Published var longitudeArray: [Double] = []
    @Published var latitudeArray: [Double] = []
    @Published var speedArray: [Double] = []
    @Published var glideRatioArray: [Double] = []
    @Published var glideRatio: Double = 0
    @Published var altitudeArray: [Double] = []
    @Published var altitude: Double = 0
    @Published var accuracyArray: [Double] = []
    func resetArrays() {
        longitudeArray = []
        latitudeArray = []
        speedArray = []
        glideRatioArray = []
        glideRatio = 0
        altitudeArray = []
        altitude = 0
        accuracyArray = []
        debugPrint("Location Manager Arrays resetted!")
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var lastLocation = CLLocation() {
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
        debugPrint(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        //debugPrint(#function, location)
        
        if lastLocation.horizontalAccuracy < 15 {
            longitudeArray.append(lastLocation.coordinate.longitude)
            latitudeArray.append(lastLocation.coordinate.latitude)
            speedArray.append(lastLocation.speed)
            glideRatioArray.append(glideRatio)
            altitudeArray.append(altitude)
            accuracyArray.append(lastLocation.horizontalAccuracy)
        } else { debugPrint("Dropped location because accuracy was over 15m.") }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func start() {
        switch LocationManager.shared.locationStatus {
        case .notDetermined:
            debugPrint("CL: Awaiting user prompt...")
        case .restricted:
            fatalError("CL Authorization restricted!")
        case .denied:
            fatalError("CL Authorization denied!")
        case .authorizedAlways:
            debugPrint("CL Authorized!")
        case .authorizedWhenInUse:
            debugPrint("CL Authorized when in use!")
        case .none:
            debugPrint("CL Authorization None!")
        @unknown default:
            fatalError("Unknown CL Authorization Status!")
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
}
