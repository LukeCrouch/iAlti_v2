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
    private let activityType = CLActivityType.airborne
    var altimeterTimestamp = 0.0
    
    func startLocation() {
        switch LocationManager.shared.locationStatus {
        case .notDetermined:
            print("CL: Awaiting user prompt...")
        //fatalError("Awaiting CL user prompt...")
        case .restricted:
            fatalError("CL Authorization restricted!")
        case .denied:
            fatalError("CL Authorization denied!")
        case .authorizedAlways:
            print("CL Authorized!")
        case .authorizedWhenInUse:
            print("CL Authorized when in use!")
        case .none:
            print("CL Authorization None!")
        @unknown default:
            fatalError("Unknown CL Authorization Status!")
        }
        LocationManager.shared.start()
        globals.isLocationStarted = true
    }
    
    func stopAltimeter() {
        Altimeter.shared.stopRelativeAltitudeUpdates()
        globals.isAltimeterStarted = false
    }
    
    func startAltimeter() {
        var timestamp = 0.0
        
        if Altimeter.isRelativeAltitudeAvailable() {
            switch Altimeter.authorizationStatus() {
            case .notDetermined: // Handle state before user prompt
                print("CM: Awaiting user prompt...")
            //fatalError("Awaiting CM user prompt...")
            case .restricted: // Handle system-wide restriction
                fatalError("CM Authorization restricted!")
            case .denied: // Handle user denied state
                fatalError("CM Authorization denied!")
            case .authorized: // Ready to go!
                print("CM Authorized!")
            @unknown default:
                fatalError("Unknown CM Authorization Status!")
            }
            Altimeter.shared.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
                if let trueData = data {
                    print(trueData)
                    globals.pressure = trueData.pressure.doubleValue * 10
                    globals.barometricAltitude =  8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                    globals.speedV = (trueData.relativeAltitude.doubleValue - globals.relativeAltitude) / (trueData.timestamp - timestamp)
                    globals.glideRatio = (LocationManager.shared.lastLocation?.speed ?? 0.0) / (-1 * globals.speedV)
                    timestamp = trueData.timestamp
                    globals.relativeAltitude = trueData.relativeAltitude.doubleValue
                } else {
                    print("Error starting relative Altitude Updates: \(error?.localizedDescription ?? "Unknown Error")")
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
                        print("Start Button pressed")
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
                        print("Stop Button pressed")
                        stopAltimeter()
                        LocationManager.shared.stop()
                        globals.isLocationStarted = false
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
                        print("Reset Button pressed")
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
                        print("Settings Button pressed")
                        showModal.toggle()
                    }, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                    })
                    Text("Settings")
                }.sheet(isPresented: $showModal) {
                    SettingsView()
                        .environmentObject(globals)
                        .environmentObject(userSettings)
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.showModal = false }
                            }
                        })
                }
            }
        }.navigationBarTitle("Controls")
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(view: .constant(0))
    }
}
