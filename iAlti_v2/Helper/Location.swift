//
//  Location.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import CoreLocation
import Combine
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Purpose Key")
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    @Published var geocodedLocation = "Unknown"
    
    @Published var isLocationStarted = false {
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
    // MARK: Arrays
    @Published var locationArray: [CLLocation] = []
    @Published var speedVerticalArray: [Double] = []
    @Published var altitudeArray: [Double] = []
    
    func resetArrays() {
        locationArray = []
        speedVerticalArray = []
        altitudeArray = []
        debugPrint("Location Manager Arrays resetted!")
    }
    
    struct Main: Codable {
        var pressure: Double?
    }
    
    struct Weather: Codable {
        var main: Main?
    }
    // MARK: Geocode
    func geocode(location: CLLocation) {
        debugPrint("Starting Geocoding for location: \(location)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                let placemark: CLPlacemark? = placemarks?[0]
                self.geocodedLocation = placemark?.locality ?? "Unknown"
                debugPrint("Geocoded Take Off: \(self.geocodedLocation)")
            } else {
                debugPrint("Error geocoding location: \(error?.localizedDescription ?? "Unknown Error")")
            }
        })
    }
    // MARK: Auto Calibration
    func autoCalib() {
        guard let location = lastLocation else { debugPrint("Did not calibrate because of missing location!"); return }
        let pressureCall = "ZmY1N2FmZThkOGY2N2U2MzIwNmVmZmQ2MTM3NmMzZDc="
        let pressureCallNew: String = pressureCall.model!
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(pressureCallNew)") else {
            debugPrint("Invalid Openweathermap URL")
            return
        }
        
        let request = URLRequest(url: url)
        debugPrint("Request ", request)
        
        URLSession.shared.dataTask(with: request) { data, decodedResponse, error in
            debugPrint("URLSession started")
            if let data = data {
                debugPrint("URLSession data received", data)
                if let decodedResponse = try? JSONDecoder().decode(Weather.self, from: data) {
                    debugPrint("URLSession response decoded", decodedResponse)
                    DispatchQueue.main.async {
                        UserSettings.shared.qnh = decodedResponse.main?.pressure ?? 0
                        Altimeter.shared.setOffset()
                        debugPrint("Calibrated with a pulled pressure of", decodedResponse.main?.pressure ?? 0)
                    }
                    return
                }
            }
            debugPrint("Fetch failed: \(error?.localizedDescription ?? "Unknown error"):")
            debugPrint("Error", error ?? "nil")
        }.resume()
    }
    // MARK: Updates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        debugPrint(#function, status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        if location.horizontalAccuracy < 15 {
            locationArray.append(location)
            altitudeArray.append(Altimeter.shared.barometricAltitude)
            speedVerticalArray.append(Altimeter.shared.speedVertical)
        } else { debugPrint("Dropped location because accuracy was over 15m.") }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    // MARK: Start & Stop
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        self.isLocationStarted = false
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
        self.isLocationStarted = true
    }
}
