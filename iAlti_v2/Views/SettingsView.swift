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
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple", "Black"]
    private let voiceOutputs = ["Off", "Glide Ratio", "Speed vertical", "Speed horizontal", "Altitude", "Variometer"]
    
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
            // MARK: Dashboard
            Section(header: Text("Dashboard")) {
                HStack {
                    if locationManager.didTakeOff {
                        Text("True")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    } else {
                        Text("False")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }
                    Text("Did TakeOff")
                }
                HStack {
                    if locationManager.didLand {
                        Text("True")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    } else {
                        Text("False")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }
                    Text("Did Land")
                }
                HStack {
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
                    Text("Barometer")
                }
                HStack {
                    Text("\(altimeter.pressure, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Pressure [hPa]")
                }
                HStack {
                    Text("\(altimeter.barometricAltitude, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Altitude MSL [m]")
                }
                HStack {
                    Text("\(altimeter.speedVertical, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Vertical Speed [m/s]")
                }
                HStack {
                    if locationManager.isLocationStarted {
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
                    Text("\(locationManager.lastLocation?.altitude ?? 0, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Altitude MSL [m]")
                }
                HStack {
                    Text("\(locationManager.lastLocation?.verticalAccuracy ?? 0, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Vertical Accuracy [m]")
                }
                HStack {
                    Text("\(locationManager.lastLocation?.horizontalAccuracy ?? 0, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Horizontal Accuracy [m]")
                }
            }
            // MARK: Controls
            Section(header: Text("Controls")) {
                if locationManager.isLocationStarted {
                    Button(action: {
                        stopButton()
                    }, label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop GPS and Barometer Logging")}
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    })
                } else {
                    Button(action: {
                        startButton()
                    }, label: {HStack {
                        Image(systemName: "forward")
                        Text("Start GPS and Barometer Logging")}
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
                                Text("Run Altimeter")}
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            })
                        }
                }
                Button(action: {
                    if locationManager.isLocationStarted {
                        debugPrint("Auto Calibration started")
                        locationManager.autoCalib()
                    } else {
                        alertTitle = "Warning"
                        alertMessage = "Start GPS services before calibrating."
                        showAlert = true
                    }
                }, label: {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Auto Calibration")
                    }
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
            }
            // MARK: Customize
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
                Picker(selection: $userSettings.voiceOutputSelection, label: Text("Voice Output")) {
                    ForEach(0 ..< self.voiceOutputs.count) {
                        Text(voiceOutputs[$0]).foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }
                }
                Picker(selection: $userSettings.voiceLanguageSelection, label: Text("Voice Language")) {
                    ForEach(0 ..< userSettings.voiceLanguages.count) {
                        let text = (userSettings.voiceLanguages[$0]["languageName"] ?? "Unknown") + " " + (userSettings.voiceLanguages[$0]["voiceName"] ?? "")
                        Text(text).foregroundColor(userSettings.colors[userSettings.colorSelection])
                    }
                }
                Button(action: {
                    let cachedSelection = userSettings.voiceOutputSelection
                    userSettings.voiceOutputSelection = 1
                    voiceOutput()
                    userSettings.voiceOutputSelection = cachedSelection
                },
                label: {
                    HStack {
                        Image(systemName: "speaker.wave.3")
                        Text("Test voice ouput")}
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
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
                Button(action: {
                    playVario()
                },
                label: {
                    HStack {
                        Image(systemName: "speaker.wave.3")
                        Text("Test Vario")}
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: { prepareVoiceList() })
        .onChange(of: userSettings.qnh, perform: {_ in Altimeter.shared.setOffset() })
        .onChange(of: locationManager.didLand, perform: {_ in
            alertTitle = "Landed!"
            alertMessage = "Landing detected: Finished logging and saving file. Flight Time: \(duration)"
            showAlert = true
            stopButton()
        })
    }
}
