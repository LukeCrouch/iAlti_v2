//
//  MainView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            if (globals.relativeAltitude + userSettings.offset) > 999 || (globals.relativeAltitude + userSettings.offset) < -999 {
                Text("\((globals.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
                    .padding(.top)
            } else {
                Text("\(globals.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
                    .padding(.top)
            }
            Text("Altitude [m]")
                .font(.system(size: 15))
            Divider()
            if globals.glideRatio > 99 || globals.glideRatio < 0 {
                Image(systemName: "face.smiling")
                    .font(.system(size: 60))
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            } else if globals.glideRatio.isNaN || globals.glideRatio == 0 {
                Text("0")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            } else {
                Text("\(globals.glideRatio, specifier: "%.1f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }
            Text("Glide Ratio")
                .font(.system(size: 15))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}
