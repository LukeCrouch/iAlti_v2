//
//  OverView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct OverViewLine: View {
    @ObservedObject private var userSettings = UserSettings.shared
    
    var name: String
    var value: Double
    var decimals: Int
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10))
            Spacer()
            Text("\(value, specifier: "%.\(decimals)f")")
                .font(.system(size: 20))
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
        }
    }
}

struct OverView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    
    @State private var toggleAlti = false
    @State private var toggleLoc = false
    
    var body: some View {
        VStack {
            HStack {
                Text("**Barometer**")
                    .font(.system(size: 15))
                if altimeter.isAltimeterStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .opacity(toggleAlti ? 0 : 1)
                        .onAppear(perform: {toggleAlti.toggle()})
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1))
                } else {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.gray)
                }
            }
            if userSettings.unitSelection == 0 { // metric
                OverViewLine(name: "Pressure [hPa]", value: altimeter.pressure, decimals: 2)
                OverViewLine(name: "Altitude MSL [m]", value: altimeter.barometricAltitude, decimals: 0)
                OverViewLine(name: "Vertical Speed [m/s]", value: altimeter.speedVertical, decimals: 1)
            } else { // imperial
                OverViewLine(name: "Pressure [psf]", value: altimeter.pressure * 2.0885434, decimals: 2)
                OverViewLine(name: "Altitude MSL [feet]", value: altimeter.barometricAltitude * 3.28084, decimals: 0)
                OverViewLine(name: "Vertical Speed [mph]", value: altimeter.speedVertical * 2.23694, decimals: 1)
            }
            Divider()
            HStack {
                Text("**GPS**")
                    .font(.system(size: 15))
                if LocationManager.shared.isLocationStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .opacity(toggleLoc ? 0 : 1)
                        .onAppear(perform: {toggleLoc.toggle()})
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1))
                } else {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.gray)
                }
            }
            if userSettings.unitSelection == 0 { // metric
                OverViewLine(name: "Horizontal Accuracy [m]", value: LocationManager.shared.lastLocation?.horizontalAccuracy ?? 0, decimals: 0)
                OverViewLine(name: "Vertical Accuracy [m]", value: LocationManager.shared.lastLocation?.verticalAccuracy ?? 0, decimals: 0)
            } else { // imperial
                OverViewLine(
                    name: "Horizontal Accuracy [feet]",
                    value: LocationManager.shared.lastLocation?.horizontalAccuracy ?? 0 * 3.28084,
                    decimals: 0
                )
                OverViewLine(
                    name: "Vertical Accuracy [feet]",
                    value: LocationManager.shared.lastLocation?.verticalAccuracy ?? 0 * 3.28084,
                    decimals: 0
                )
            }
        }
    }
}
