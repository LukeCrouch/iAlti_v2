//
//  SettingsView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreLocation
import CoreData
import Combine

struct SettingsView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject private var userSettings = UserSettings.shared
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    
    let connectivityProvider = WatchConnectivityProvider()
    
    @Binding var view: Int
    @State private var showAlert = false
    @State private var selection: Int = 0
    
    @State private var toggleAlti = false
    @State private var toggleLoc = false
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple", "Black"]
    
    @State var startTime = Date()
    
    private func startButton() {
        if LocationManager.shared.isLocationStarted {
            debugPrint("Tracking already started.")
        } else {
            debugPrint("Start Button pressed.")
            LocationManager.shared.geocodedLocation = "Unknown"
            startTime = Date()
            Altimeter.shared.start()
            LocationManager.shared.start()
            view = 0
            LocationManager.shared.isLocationStarted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                geocode(location: LocationManager.shared.lastLocation)
            }
        }
    }
    
    private func stopButton() {
        debugPrint("Stop Button pressed")
        Altimeter.shared.stopRelativeAltitudeUpdates()
        LocationManager.shared.stop()
        LocationManager.shared.isLocationStarted = false
        toggleLoc = false
        toggleAlti = false
        Altimeter.shared.isAltimeterStarted = false
        PersistenceManager.shared.saveLog(duration: DateInterval(start: startTime, end: Date()).duration)
        view = 1
    }
    
    var body: some View {
        Form {
            Section(header: Text("Dashboard")) {
                HStack {
                    if Altimeter.shared.isAltimeterStarted {
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
                    Text("Barometer")
                }
                HStack {
                    Text("\(Altimeter.shared.pressure, specifier: "%.2f")")
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    Text("Pressure [hPa]")
                }
                HStack {
                    Text("\(Altimeter.shared.barometricAltitude, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Altitude MSL [m]")
                }
                HStack {
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
                    Text("GPS")
                }
                HStack {
                    Text("\(LocationManager.shared.lastLocation.horizontalAccuracy, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Horizontal Accuracy [m]")
                }
                HStack {
                    Text("\(LocationManager.shared.lastLocation.verticalAccuracy, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Vertical Accuracy [m]")
                }
            }
            Section(header: Text("Controls")) {
                Button(action: {
                    startButton()
                }, label: {HStack {
                    Image(systemName: "play.fill")
                    Text("Start GPS and Barometer Logging")}
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
                Button(action: {
                    stopButton()
                }, label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop GPS and Barometer Logging")}
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
                Button(action: {
                    debugPrint("Reset Button pressed")
                    Altimeter.shared.stopRelativeAltitudeUpdates()
                    Altimeter.shared.start()
                    userSettings.offset = 0
                }, label: {HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Reset Altimeter")}
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
                Button(action: {
                    if LocationManager.shared.isLocationStarted {
                        debugPrint("Auto Calibration started")
                        LocationManager.shared.autoCalib()
                    } else {
                        showAlert = true
                    }
                }, label: {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Auto Calibration")
                    }
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Warning"), message: Text("Start GPS services before calibrating."), dismissButton: .default(Text("OK")))
                }
            }
            Section(header: Text("Altimeter")) {
                HStack {
                    Text("QNH")
                    Spacer()
                    TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
                HStack {
                    Text("Offset")
                    Spacer()
                    TextField("Offset", value: $userSettings.offset, formatter: NumberFormatter())
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
            }
            Section(header: Text("Log Defaults")) {
                HStack {
                    Text("Pilot")
                    Spacer()
                    TextField("", text: $userSettings.pilot)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
                HStack {
                    Text("Glider")
                    Spacer()
                    TextField("", text: $userSettings.glider)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
            }
            Section(header: Text("Customize")) {
                Picker(selection: $userSettings.colorSelection, label: Text("Font Color")) {
                    ForEach(0 ..< colors.count) {
                        Text(self.colors[$0]).foregroundColor(userSettings.colors[$0])
                    }.foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
            }
        }.onAppear(perform: connectivityProvider.connect)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(view: .constant(2))
    }
}
