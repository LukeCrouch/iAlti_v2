//
//  MainView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @ObservedObject private var altimeter = Altimeter.shared
    
    private var textSize: CGFloat {
        if userSettings.displaySelection == 0 { return 80 } else { return 55 }
    }
    
    var body: some View {
        VStack {
            if (altimeter.relativeAltitude + userSettings.offset) > 999 || (altimeter.relativeAltitude + userSettings.offset) < -999 {
                Text("\((altimeter.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                    .font(.system(size: textSize))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            } else {
                Text("\(altimeter.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                    .font(.system(size: textSize))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }
            Text("Altitude [m]")
                .font(.system(size: 15))
            if userSettings.displaySelection == 0 {
                Text("")
            } else if userSettings.displaySelection == 1 {
                Divider()
                if altimeter.glideRatio > 99 || altimeter.glideRatio < 0 {
                    Image(systemName: "face.smiling")
                        .font(.system(size: textSize))
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                } else if altimeter.glideRatio.isNaN || altimeter.glideRatio == 0 {
                    Text("0")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                } else {
                    Text("\(altimeter.glideRatio, specifier: "%.1f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                }
                Text("Glide Ratio")
                    .font(.system(size: 15))
            } else {
                Divider()
                Text("\(LocationManager.shared.lastLocation?.speed ?? 0, specifier: "%.1f")")
                    .font(.system(size: textSize))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
                Text("Horizontal Speed [km/h]")
                    .font(.system(size: 15))
            }
        }
    }
}
