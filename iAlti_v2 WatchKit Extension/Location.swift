//
//  Location.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreLocation
import Combine

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
    
    @Published var longitudeArray: [Double] = []
    @Published var latitudeArray: [Double] = []
    @Published var speedHorizontalArray: [Double] = []
    @Published var glideRatioArray: [Double] = []
    @Published var altitudeArray: [Double] = []
    @Published var accuracyArray: [Double] = []
    @Published var speedVerticalArray: [Double] = []
    
    func resetArrays() {
        longitudeArray = []
        latitudeArray = []
        speedHorizontalArray = []
        glideRatioArray = []
        altitudeArray = []
        accuracyArray = []
        speedVerticalArray = []
        debugPrint("Location Manager Arrays resetted!")
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
        
        if location.horizontalAccuracy < 15 {
            accuracyArray.append(location.horizontalAccuracy)
            longitudeArray.append(location.coordinate.longitude)
            latitudeArray.append(location.coordinate.latitude)
            speedHorizontalArray.append(location.speed)
            glideRatioArray.append(Altimeter.shared.glideRatio)
            altitudeArray.append(Altimeter.shared.barometricAltitude)
            speedVerticalArray.append(Altimeter.shared.speedVertical)
        } else { debugPrint("Dropped location because accuracy was over 15m.") }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func start() {
        switch locationStatus {
        case .notDetermined:
            debugPrint("CL: Awaiting user prompt...")
            //fatalError("Awaiting CL user prompt...")
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
        isLocationStarted = true
    }
    
    struct Weather: Codable {
        var main: Main?
    }

    struct Main: Codable {
        var pressure: Double?
    }
    
    func autoCalib() {
        let pressureCall = "ZmY1N2FmZThkOGY2N2U2MzIwNmVmZmQ2MTM3NmMzZDc="
        let pressureCallNew: String = pressureCall.model!
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(LocationManager.shared.lastLocation!.coordinate.latitude)&lon=\(LocationManager.shared.lastLocation!.coordinate.longitude)&appid=\(pressureCallNew)") else {
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
}
