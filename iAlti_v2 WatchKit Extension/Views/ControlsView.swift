//
//  ControlsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @Binding var view: Int
    @State private var showModal = false
    
    let connectivityProvider = PhoneConnectivityProvider()
    
    private func startLocation() {
        switch LocationManager.shared.locationStatus {
        case .notDetermined:
            debugPrint("CL: Awaiting user prompt...")
        //fatalError("Awaiting CL user prompt...")
        case .restricted:
            fatalError("CL Authorization restricted!")
        case .denied:
            fatalError("CL Authorization denied!")
        case .authorizedAlways:
            debugPrint("CL Authorized!")
        case .authorizedWhenInUse:
            debugPrint("CL Authorized when in use!")
        case .none:
            debugPrint("CL Authorization None!")
        @unknown default:
            fatalError("Unknown CL Authorization Status!")
        }
        LocationManager.shared.start()
        globals.isLocationStarted = true
    }
    
    private func stopAltimeter() {
        Altimeter.shared.stopRelativeAltitudeUpdates()
        globals.isAltimeterStarted = false
    }
    
    private func startAltimeter() {
        var timestamp = 0.0
        
        if Altimeter.isRelativeAltitudeAvailable() {
            switch Altimeter.authorizationStatus() {
            case .notDetermined: // Handle state before user prompt
                debugPrint("CM: Awaiting user prompt...")
            //fatalError("Awaiting CM user prompt...")
            case .restricted: // Handle system-wide restriction
                fatalError("CM Authorization restricted!")
            case .denied: // Handle user denied state
                fatalError("CM Authorization denied!")
            case .authorized: // Ready to go!
                debugPrint("CM Authorized!")
            @unknown default:
                fatalError("Unknown CM Authorization Status!")
            }
            Altimeter.shared.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
                if let trueData = data {
                    debugPrint(trueData)
                    globals.pressure = trueData.pressure.doubleValue * 10
                    globals.barometricAltitude =  8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                    globals.speedV = (trueData.relativeAltitude.doubleValue - globals.relativeAltitude) / (trueData.timestamp - timestamp)
                    globals.glideRatio = (LocationManager.shared.lastLocation?.speed ?? 0.0) / (-1 * globals.speedV)
                    timestamp = trueData.timestamp
                    globals.relativeAltitude = trueData.relativeAltitude.doubleValue
                } else {
                    debugPrint("Error starting relative Altitude Updates: \(error?.localizedDescription ?? "Unknown Error")")
                }
            }
        }
        globals.isAltimeterStarted = true
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: {
                        debugPrint("Start Button pressed")
                        startAltimeter()
                        startLocation()
                        view = (view + 1) % 1
                    }, label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    })
                    Text("Start")
                }
                VStack {
                    Button(action: {
                        debugPrint("Stop Button pressed")
                        stopAltimeter()
                        LocationManager.shared.stop()
                        globals.isLocationStarted = false
                        LocationManager.shared.sendLog()
                    }, label: {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    })
                    Text("Stop")
                }
            }
            HStack {
                VStack {
                    Button(action: {
                        debugPrint("Reset Button pressed")
                        stopAltimeter()
                        startAltimeter()
                        userSettings.offset = 0
                        view = (view + 1) % 1
                    }, label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    })
                    Text("Reset")
                }
                VStack {
                    Button(action: {
                        debugPrint("Settings Button pressed")
                        showModal.toggle()
                    }, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                    })
                    Text("Settings")
                }.sheet(isPresented: $showModal) {
                    SettingsView()
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.showModal = false }
                            }
                        })
                }
            }
        }
        .navigationBarTitle("iAlti v2")
        .onAppear(perform: connectivityProvider.connect)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(view: .constant(0))
    }
}
