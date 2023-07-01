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
    
    let locationManager = LocationManager.shared
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    private var textSize: CGFloat {
        if WKInterfaceDevice.current().screenBounds.height < 230 {
            if userSettings.displaySelection == 0 { return 80 } else { return 40 }
        }
        else {
            if userSettings.displaySelection == 0 { return 80 } else { return 55 }
        }
    }
    
    var body: some View {
        VStack {
            if userSettings.unitSelection == 0 { // metric
                if (altimeter.relativeAltitude + userSettings.offset) > 999 || (altimeter.relativeAltitude + userSettings.offset) < -999 {
                    Text("\((altimeter.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [km]")
                        .font(.system(size: 15))
                } else {
                    Text("\(altimeter.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [m]")
                        .font(.system(size: 15))
                }
            } else { //imperial
                if ((altimeter.relativeAltitude + userSettings.offset) * 3.28084) > 999 || (altimeter.relativeAltitude + userSettings.offset) < -999 {
                    Text("\((altimeter.relativeAltitude + userSettings.offset) * 3.28084 / 5280, specifier: "%.2f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [miles]")
                        .font(.system(size: 15))
                } else {
                    Text("\((altimeter.relativeAltitude + userSettings.offset)  * 3.28084, specifier: "%.0f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [feet]")
                        .font(.system(size: 15))
                }
            }
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
            } else if userSettings.displaySelection == 2 {
                Divider()
                if userSettings.unitSelection == 0 { // metric
                    Text("\((locationManager.lastLocation?.speed ?? 0) * 3.6, specifier: "%.1f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Horizontal Speed [km/h]")
                        .font(.system(size: 15))
                } else { // imperial
                    Text("\((locationManager.lastLocation?.speed ?? 0) * 2.23694, specifier: "%.1f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Horizontal Speed [mph]")
                        .font(.system(size: 15))
                }
            }
            else {
                if userSettings.unitSelection == 0 { // metric
                    Divider()
                    Text("\(altimeter.speedVertical * 3.6, specifier: "%.1f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Vertical Speed [km/h]")
                        .font(.system(size: 15))
                } else { // imperial
                    Divider()
                    Text("\(altimeter.speedVertical * 2.23694, specifier: "%.1f")")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Vertical Speed [mph]")
                        .font(.system(size: 15))
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: locationManager.showPrivacyAlert, perform: {_ in
            alertTitle = "Location Usage not allowed!"
            alertMessage = "Please got to Settings -> Privacy and allow this app to use location data (always and precise). Afterwards please restart the app."
            showAlert = locationManager.showPrivacyAlert
        })
    }
}
