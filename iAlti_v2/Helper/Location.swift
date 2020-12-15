//
//  Location.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import CoreLocation
import Combine
import SwiftUI

public func geocode(location: CLLocation) {
    debugPrint("Starting Geocoding for location: \(location)")
    
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
        if error == nil {
            let placemark: CLPlacemark? = placemarks?[0]
            LocationManager.shared.geocodedLocation = placemark?.locality ?? "Unknown"
            debugPrint("Geocoded Take Off: \(LocationManager.shared.geocodedLocation)")
        } else {
            debugPrint("Error geocoding location: \(error?.localizedDescription ?? "Unknown Error")")
        }
    })
}

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
    
    @Published var isLocationStarted = false
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation = CLLocation()
    
    @Published var distance: Double = 0
    @Published var speedVerticalMax: Double = 0
    @Published var longitudeArray: [Double] = []
    @Published var latitudeArray: [Double] = []
    @Published var speedHorizontalArray: [Double] = []
    @Published var speedVerticalArray: [Double] = []
    @Published var glideRatioArray: [Double] = []
    @Published var altitudeArray: [Double] = []
    @Published var accuracyArray: [Double] = []
    
    func resetArrays() {
        longitudeArray = []
        latitudeArray = []
        speedHorizontalArray = []
        speedVerticalArray = []
        glideRatioArray = []
        altitudeArray = []
        accuracyArray = []
        speedVerticalMax = 0
        distance = 0
        debugPrint("Location Manager Arrays resetted!")
    }
    
    struct Main: Codable {
        var pressure: Double?
    }

    struct Weather: Codable {
        var main: Main?
    }
    
    func autoCalib() {
        let pressureCall = "ZmY1N2FmZThkOGY2N2U2MzIwNmVmZmQ2MTM3NmMzZDc="
        let pressureCallNew: String = pressureCall.model!
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(LocationManager.shared.lastLocation.coordinate.latitude)&lon=\(LocationManager.shared.lastLocation.coordinate.longitude)&appid=\(pressureCallNew)") else {
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
                        debugPrint("Calibrated with a pulled pressure of", decodedResponse.main?.pressure ?? 0)
                        UserSettings.shared.offset = 8400 * (UserSettings.shared.qnh - Altimeter.shared.pressure) / UserSettings.shared.qnh
                    }
                    return
                }
            }
            debugPrint("Fetch failed: \(error?.localizedDescription ?? "Unknown error"):")
            debugPrint("Error", error ?? "nil")
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        debugPrint(#function, locationStatus!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        //debugPrint(#function, location)
        
        if lastLocation.horizontalAccuracy < 15 {
            longitudeArray.append(lastLocation.coordinate.longitude)
            latitudeArray.append(lastLocation.coordinate.latitude)
            speedHorizontalArray.append(lastLocation.speed)
            glideRatioArray.append(Altimeter.shared.glideRatio)
            altitudeArray.append(Altimeter.shared.barometricAltitude)
            accuracyArray.append(lastLocation.horizontalAccuracy)
            speedVerticalArray.append(Altimeter.shared.speedVertical)
            
            if accuracyArray.count > 2 {
                let currentDistance = lastLocation.distance(from: CLLocation(latitude: latitudeArray[0], longitude: longitudeArray[0]))
                if currentDistance > distance { distance = currentDistance }
            }
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
