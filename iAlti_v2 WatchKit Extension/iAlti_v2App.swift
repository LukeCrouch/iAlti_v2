//
//  iAlti_v2App.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI
import CoreLocation
import Combine
import CoreMotion

class UserSettings: ObservableObject {
    @Published var colors = [Color.green, Color.white, Color.red, Color.blue, Color.orange, Color.yellow, Color.pink, Color.purple]
    @Published var colorSelection: Int = 0
    @Published var qnh: Double = 1013.25
    @Published var offset: Double = 0
}

class Globals: ObservableObject {
    @Published var pressure: Double = 0
    @Published var isAltimeterStarted = false
    @Published var isLocationStarted = false
    @Published var barometricAltitude: Double = 0
    @Published var relativeAltitude: Double = 0
    @Published var speedV: Double = 0
    @Published var glideRatio: Double = 0
}

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

public extension String {
    var model: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }
}

struct iAlti_v2App: App {
    @StateObject var globals = Globals()
    @StateObject var userSettings = UserSettings()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(globals)
                    .environmentObject(userSettings)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
