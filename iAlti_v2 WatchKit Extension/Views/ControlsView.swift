//
//  ControlsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ControlsView: View {
    @Binding var view: Int
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var userSettings = UserSettings.shared
    
    @State private var showingAlert = false
    @State private var showModal = false
    
    private let connectivityProvider = PhoneConnectivityProvider()
    
    @State var startDate = Date()
    @State var duration: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if locationManager.isLocationStarted {
                        Button(action: {
                            debugPrint("Stop Logging Button pressed")
                            WKInterfaceDevice().play(.stop)
                            duration = DateInterval(start: startDate, end: Date()).duration
                            locationManager.stop()
                            altimeter.stop()
                            connectivityProvider.send(duration: duration)
                        },
                        label: {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        })
                        Text("Stop Logging")
                    } else {
                        Button(action: {
                            debugPrint("Start Logging Button pressed")
                            WKInterfaceDevice().play(.start)
                            startDate = Date()
                            altimeter.start()
                            locationManager.start()
                            view = (view + 1) % 1
                        }, label: {
                            Image(systemName: "play.fill")
                                .foregroundColor(.green)
                                .font(.title)
                        })
                        Text("Logging")
                    }
                }
                if !(locationManager.isLocationStarted) {
                    VStack {
                        if altimeter.isAltimeterStarted {
                            Button(action: {
                                debugPrint("Altimeter Stop Button pressed")
                                WKInterfaceDevice().play(.stop)
                                altimeter.stop()
                            }, label: {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.blue)
                                    .font(.title)
                            })
                        } else {
                            Button(action: {
                                debugPrint("Altimeter Start Button pressed")
                                WKInterfaceDevice().play(.start)
                                altimeter.start()
                                view = (view + 1) % 1
                            }, label: {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.blue)
                                    .font(.title)
                            })
                        }
                        Text("Altimeter")
                    }
                }
            }
            HStack {
                VStack {
                    Button(action: {
                        debugPrint("Settings Button pressed")
                        showModal.toggle()
                    }, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.orange)
                            .font(.title)
                    })
                    Text("Settings")
                }
                .sheet(isPresented: $showModal) {
                    SettingsView()
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.showModal = false }
                            }
                        })
                }
                VStack {
                    Spacer()
                    Button(action: {
                        if locationManager.isLocationStarted {
                            debugPrint("Auto Calibration started")
                            LocationManager.shared.autoCalib()
                        } else {
                            WKInterfaceDevice().play(.failure)
                            self.showingAlert = true
                        }
                    }, label: {
                        Image(systemName: "icloud.and.arrow.down")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    })
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Warning"), message: Text("Start GPS services before calibrating."), dismissButton: .default(Text("OK")))
                    }
                    .frame(width: 90.0, height: 50.0)
                    Text("Calibration")
                }
            }
        }
    }
}
