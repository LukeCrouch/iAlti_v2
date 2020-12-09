//
//  OverView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct OverViewLine: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
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
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @State private var toggleAlti = false
    @State private var toggleLoc = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Barometer")
                    .font(.system(size: 15))
                if globals.isAltimeterStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.red)
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
            OverViewLine(name: "Pressure [hPa]", value: globals.pressure, decimals: 2)
            OverViewLine(name: "Elevation [m]", value: globals.barometricAltitude, decimals: 0)
            OverViewLine(name: "Vertical Speed [m/s]", value: globals.speedV, decimals: 1)
            Divider()
            HStack {
                Text("GPS")
                    .font(.system(size: 15))
                if globals.isLocationStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.red)
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
            OverViewLine(name: "Horizontal Accuracy [m]", value: LocationManager.shared.lastLocation?.horizontalAccuracy ?? 0.0, decimals: 0)
            OverViewLine(name: "Vertical Accuracy [m]", value: LocationManager.shared.lastLocation?.verticalAccuracy ?? 0.0, decimals: 0)
        }
    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
