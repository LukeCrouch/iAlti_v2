//
//  MainView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            if (Altimeter.shared.relativeAltitude + UserSettings.shared.offset) > 999 || (Altimeter.shared.relativeAltitude + UserSettings.shared.offset) < -999 {
                Text("\((Altimeter.shared.relativeAltitude + UserSettings.shared.offset) / 1000, specifier: "%.2f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    .transition(.opacity)
                    .padding(.top)
            } else {
                Text("\(Altimeter.shared.relativeAltitude + UserSettings.shared.offset, specifier: "%.0f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    .transition(.opacity)
                    .padding(.top)
            }
            Text("Altitude [m]")
                .font(.system(size: 15))
            Divider()
            if Altimeter.shared.glideRatio > 99 || Altimeter.shared.glideRatio < 0 {
                Image(systemName: "face.smiling")
                    .font(.system(size: 60))
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    .transition(.opacity)
            } else if Altimeter.shared.glideRatio.isNaN || Altimeter.shared.glideRatio == 0 {
                Text("0")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    .transition(.opacity)
            } else {
                Text("\(Altimeter.shared.glideRatio, specifier: "%.1f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
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
