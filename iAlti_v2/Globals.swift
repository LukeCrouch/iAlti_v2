//
//  Globals.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.11.20.
//

import Foundation
import CoreLocation

final class Globals: ObservableObject {
    static var shared = Globals()
    
    @Published var pressure: Double = 0
    @Published var isAltimeterStarted = false
    @Published var isLocationStarted = false
    @Published var barometricAltitude: Double = 0
    @Published var relativeAltitude: Double = 0
    @Published var speedV: Double = 0
    @Published var speedH: Double = 0
    @Published var glideRatio: Double = 0
    @Published var lat: Double = 48
    @Published var lon: Double = 12
    @Published var geocodedLocation: String = "Unknown"
}

struct Weather: Codable {
    var main: Main?
}

struct Main: Codable {
    var pressure: Double?
}

extension Notification.Name {
    static let didReceiveLocation = Notification.Name("didReceiveLocation")
}

public extension String {
    var model: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }
}

public extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}

public func geocode(location: CLLocation) {
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    debugPrint("Starting Geocoding for location: \(location)")
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
        if error == nil {
            placemark = placemarks?[0]
            Globals.shared.geocodedLocation = placemark?.locality ?? "Unknown"
            debugPrint("Geocoded Take Off: \(Globals.shared.geocodedLocation)")
        } else {
            placemark = nil
            debugPrint("Error geocoding location: \(error?.localizedDescription ?? "Unknown Error")")
        }
    })
}
