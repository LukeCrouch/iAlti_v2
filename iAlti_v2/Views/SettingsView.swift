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
    // MARK: Variables
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var viewSelection: ViewSelection
    
    @ObservedObject private var userSettings = UserSettings.shared
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    
    let connectivityProvider = WatchConnectivityProvider()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    @State private var selection: Int = 0
    
    @State private var toggleAlti = false
    @State private var toggleLoc = false
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple", "Black"] //If this is changed, also change the For Each Loops
    private let unitSystems = ["Metric", "Imperial"]
    
    @State var startDate = Date()
    @State var duration: Double = 0
    
    private func startButton() {
        debugPrint("Start Button pressed.")
        startDate = Date()
        viewSelection.view = 0
        altimeter.start()
        locationManager.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {locationManager.geocode(location: locationManager.lastLocation!)
        }
    }
    
    // MARK: Functions
    func stopButton() {
        debugPrint("Stop Button pressed")
        locationManager.didLand = true
        viewSelection.view = 1
        duration = DateInterval(start: startDate, end: Date()).duration
        altimeter.stop()
        locationManager.stop()
        toggleLoc = false
        toggleAlti = false
        PersistenceManager.shared.saveLog(duration: duration)
    }
    
    // MARK: View
    var body: some View {
        Form {
            // MARK: Controls
            Section(header: Text("Controls")) {
                if locationManager.isLocationStarted {
                    Button(action: {
                        stopButton()
                    }, label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop Variometer")}
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    })
                } else {
                    Button(action: {
                        startButton()
                        locationManager.autoCalib()
                    }, label: {HStack {
                        Image(systemName: "forward")
                        Text("Start Variometer")}
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }) }
                if !(locationManager.isLocationStarted) {
                    if altimeter.isAltimeterStarted {
                        Button(action: {
                            debugPrint("Altimeter Stop Button pressed")
                            altimeter.stop()
                        }, label: {HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop Altimeter")}
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        }) } else {
                            Button(action: {
                                debugPrint("Altimeter Start Button pressed")
                                altimeter.start()
                            }, label: {HStack {
                                Image(systemName: "play")
                                Text("Start Altimeter only")}
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            })
                        }
                }
                Button(action: {
                    if locationManager.isLocationStarted {
                        locationManager.autoCalib()
                    } else {
                        alertTitle = "Warning"
                        alertMessage = "Start Variometer before calibrating."
                        showAlert = true
                    }
                }, label: {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Auto Calibrate Altimeter")
                    }
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
            }
            // MARK: Settings
            Section(header: Text("Barometer")) {
                HStack {
                    Text("QNH")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                            .frame(alignment: .center)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("hPa")
                    } else { //imperial
                        TextField("", value: $userSettings.qnhImperial, formatter: NumberFormatter())
                            .frame(alignment: .center)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("psf")
                    }
                    Spacer()
                }
                HStack {
                    Text("Offset")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        TextField("Offset", value: $userSettings.offset, formatter: NumberFormatter())
                            .frame(alignment: .center)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m")
                    } else { //imperial
                        TextField("Offset", value: $userSettings.offsetImperial, formatter: NumberFormatter())
                            .frame(alignment: .center)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("feet")
                    }
                    Spacer()
                }
            }
            Section(header: Text("Log File Defaults")) {
                HStack {
                    Text("Pilot")
                        .frame(width: 100, alignment: .leading)
                    TextField("", text: $userSettings.pilot)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
                HStack {
                    Text("Glider")
                        .frame(width: 100, alignment: .leading)
                    TextField("", text: $userSettings.glider)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
            }
            Section(header: Text("Customize")) {
                Toggle(isOn: $userSettings.mapTrackingMode){
                    Text("Rotate map with heading:")
                }
                Picker(selection: $userSettings.colorSelection, label: Text("Font Color")) {
                    ForEach(0 ..< 9) {
                        Text(self.colors[$0]).foregroundColor(userSettings.colors[$0])
                    }.foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
                Picker(selection: $userSettings.unitSelection, label: Text("Unit System")) {
                    ForEach(0 ..< 2) {
                        Text(self.unitSystems[$0])
                    }.foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
            }
            // MARK: Dashboard
            Section(header: Text("Dashboard")) {
                HStack {
                    if altimeter.isAltimeterStarted {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .scaleEffect(0.5)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .opacity(toggleAlti ? 0 : 1)
                            .onAppear(perform: {toggleAlti.toggle()})
                            .animation(
                                Animation
                                    .easeInOut(duration: 1)
                                    .repeatForever(autoreverses: true)
                                    .speed(1),
                                value: toggleAlti)
                    } else {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .scaleEffect(0.5)
                            .foregroundColor(.gray)
                    }
                    Text("**Barometer**")
                }
                HStack {
                    Text("Pressure")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(altimeter.pressure, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("hPa")
                    } else { // imperial
                        Text("\(altimeter.pressure * 2.0885434, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("psf")
                    }
                }
                HStack {
                    Text("Altitude MSL")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(altimeter.barometricAltitude, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m")
                    } else { // imperial
                        Text("\(altimeter.barometricAltitude * 3.28084, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("feet")
                    }
                }
                HStack {
                    Text("Vertical Speed")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(altimeter.speedVertical, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m/s")
                    } else { // imperial
                        Text("\(altimeter.speedVertical * 2.23694, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("mph")
                    }
                }
                HStack {
                    if locationManager.isLocationStarted {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .scaleEffect(0.5)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .opacity(toggleLoc ? 0 : 1)
                            .onAppear(perform: {toggleLoc.toggle()})
                            .animation(
                                Animation
                                    .easeInOut(duration: 1)
                                    .repeatForever(autoreverses: true)
                                    .speed(1),
                                value: toggleLoc)
                    } else {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .scaleEffect(0.5)
                            .foregroundColor(.gray)
                    }
                    Text("**GPS**")
                        .frame(width: 60, alignment: .leading)
                }
                HStack {
                    Text("Altitude MSL")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(locationManager.lastLocation?.altitude ?? 0, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m")
                    } else { // imperial
                        Text("\(locationManager.lastLocation?.altitude ?? 0 * 3.28084, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("feet")
                    }
                }
                HStack {
                    Text("Vertical Accuracy")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(locationManager.lastLocation?.verticalAccuracy ?? 0, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m")
                    } else { // imperial
                        Text("\(locationManager.lastLocation?.verticalAccuracy ?? 0 * 3.28084, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("feet")
                    }
                }
                HStack {
                    Text("Horizontal Accuracy")
                        .frame(width: 200, alignment: .leading)
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(locationManager.lastLocation?.horizontalAccuracy ?? 0, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("m")
                    } else { // imperial
                        Text("\(locationManager.lastLocation?.horizontalAccuracy ?? 0 * 3.28084, specifier: "%.2f")")
                            .frame(alignment: .leading)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("feet")
                    }
                }
                HStack {
                    Text("Heading Accuracy")
                        .frame(width: 200, alignment: .leading)
                    if (locationManager.lastLocation?.course ?? 0) > 0 {
                        Text("\(locationManager.lastLocation?.courseAccuracy ?? 0, specifier: "%.2f")")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Spacer()
                        Text("°")
                    } else {
                        Text("Unavailable")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }
                }
            }
            // MARK: Support
            Section(header: Text("Support")) {
                Button(action: {
                    let supportEmail = "lukaswheldon@yahoo.de"
                    if let emailURL = URL(string: "mailto:\(supportEmail)"), UIApplication.shared.canOpenURL(emailURL)
                    {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Questions or problems?")}
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: userSettings.qnh, perform: {_ in
            userSettings.qnhImperial = userSettings.qnh * 2.0885434
            Altimeter.shared.setOffset()
        })
        .onChange(of: userSettings.qnhImperial, perform : {_ in userSettings.qnh = userSettings.qnhImperial / 2.0885434})
        .onChange(of: userSettings.offsetImperial, perform: {_ in userSettings.offset = userSettings.offsetImperial / 3.28084 })
        .onChange(of: userSettings.offset, perform: {_ in userSettings.offsetImperial = userSettings.offset * 3.28084 })
        .onChange(of: locationManager.didLand, perform: {_ in
            alertTitle = "Landed!"
            alertMessage = "Landing detected: Finished logging and saving file. Flight Time: \(duration.asDateString(style: .positional))"
            showAlert = true
            stopButton()
        })
        .onChange(of: locationManager.showPrivacyAlert, perform: {_ in
            alertTitle = "Location Usage not allowed!"
            alertMessage = "Please got to Settings -> Privacy and allow this app to use location data (always and precise). Afterwards please restart the app."
            showAlert = locationManager.showPrivacyAlert
        })
    }
}
