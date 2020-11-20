//
//  Globals.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.11.20.
//

import Foundation

final class Globals: ObservableObject {
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
