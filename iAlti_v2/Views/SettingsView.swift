//
//  SettingsView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import CoreLocation
import CoreData

struct SettingsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.managedObjectContext) var context
    
    let connectivityProvider = WatchConnectivityProvider(persistentContainer: NSPersistentContainer())
    
    @State private var results = [Weather]()
    
    @Binding var view: Int
    @State private var showAlert = false
    @State private var selection: Int = 0
    
    @State private var toggleAlti = false
    @State private var toggleLoc = false
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple", "Black"]
    
    @State var locations = [CLLocation]()
    @State var startDate = Date()
    @State var duration: Double = 0
    @State var takeOff: String = "Unknown"
    @State var maxAltitude: Double = 0
    @State var distance: CLLocationDistance = 0
    
    private func geocode() {
        let geocoder = CLGeocoder()
        var placemark: CLPlacemark?
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            guard let currentLocation = LocationManager.shared.lastLocation else { return }
            print("Starting Geocoding for location: \(currentLocation)")
            
            geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    placemark = placemarks?[0]
                    takeOff = placemark?.locality ?? "Unknown"
                    print("Geocoded Take Off: \(takeOff)")
                } else {
                    placemark = nil
                    print("Error geocoding location: \(error?.localizedDescription ?? "Unknown Error")")
                }
            })
        }
        return
    }
    
    private func saveLog() {
        print("Saving Log")
        let newLog = Log(context: context)
        newLog.date = Date()
        newLog.glider = userSettings.glider
        newLog.pilot = userSettings.pilot
        newLog.flightTime = duration
        newLog.takeoff = takeOff
        newLog.maxAltitude = maxAltitude
        newLog.distance = distance
        newLog.speedAvg = distance / duration
        locations = LocationManager.shared.locationArray
        print("Saved \(locations.count) Log Points.")
        locations.forEach { location in
            newLog.addLogPoint(with: location, context: context) }
        do {
            try context.save()
        } catch{
            fatalError("Error Saving to persistence")
        }
        LocationManager.shared.locationArray.removeAll()
        locations.removeAll()
    }
    
    private func startButton() {
        print("Start Button pressed")
        startDate = Date()
        startAltimeter()
        LocationManager.shared.start()
        view = 0
        globals.isLocationStarted = true
        geocode()
    }
    
    private func stopButton() {
        print("Stop Button pressed")
        Altimeter.shared.stopRelativeAltitudeUpdates()
        LocationManager.shared.stop()
        globals.isLocationStarted = false
        toggleLoc = false
        toggleAlti = false
        globals.isAltimeterStarted = false
        duration = DateInterval(start: startDate, end: Date()).duration
        saveLog()
        view = 1
    }
    
    private func startAltimeter() {
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
                    print(#function, trueData)
                    globals.pressure = trueData.pressure.doubleValue * 10
                    globals.barometricAltitude =  8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                    globals.speedV = (trueData.relativeAltitude.doubleValue - globals.relativeAltitude) / (trueData.timestamp - timestamp)
                    globals.glideRatio = (LocationManager.shared.lastLocation?.speed ?? 0) / (-1 * globals.speedV)
                    globals.speedH = LocationManager.shared.lastLocation?.speed ?? 0
                    timestamp = trueData.timestamp
                    globals.relativeAltitude = trueData.relativeAltitude.doubleValue
                    if globals.barometricAltitude > maxAltitude {
                        maxAltitude = globals.barometricAltitude
                    }
                } else {
                    print("Error starting relative Altitude Updates: \(error?.localizedDescription ?? "Unknown Error")")
                }
            }
        }
        globals.isAltimeterStarted = true
    }
    
    private func autoCalib() {
        let pressureCall = "ZmY1N2FmZThkOGY2N2U2MzIwNmVmZmQ2MTM3NmMzZDc="
        let pressureCallNew: String = pressureCall.model!
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(LocationManager.shared.lastLocation!.coordinate.latitude)&lon=\(LocationManager.shared.lastLocation!.coordinate.longitude)&appid=\(pressureCallNew)") else {
            print("Invalid Openweathermap URL")
            return
        }
        
        let request = URLRequest(url: url)
        print("Request ", request)
        
        URLSession.shared.dataTask(with: request) { data, decodedResponse, error in
            print("URLSession started")
            if let data = data {
                print("URLSession data received", data)
                if let decodedResponse = try? JSONDecoder().decode(Weather.self, from: data) {
                    print("URLSession response decoded", decodedResponse)
                    DispatchQueue.main.async {
                        userSettings.qnh = decodedResponse.main?.pressure ?? 0
                        print("Calibrated with a pulled pressure of", decodedResponse.main?.pressure ?? 0)
                        userSettings.offset = 8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error"):")
            print("Error", error ?? "nil")
        }.resume()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Dashboard")) {
                HStack {
                    if globals.isAltimeterStarted {
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
                    Text("\(globals.pressure, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Pressure [hPa]")
                }
                HStack {
                    Text("\(globals.barometricAltitude, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Altitude MSL [m]")
                }
                HStack {
                    if globals.isLocationStarted {
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
                    Text("\(LocationManager.shared.lastLocation?.altitude ?? 0, specifier: "%.2f")")
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Elevation MSL [m]")
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
                    print("Reset Button pressed")
                    Altimeter.shared.stopRelativeAltitudeUpdates()
                    startAltimeter()
                    userSettings.offset = 0
                }, label: {HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Reset Altimeter")}
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                })
                Button(action: {
                    if globals.isLocationStarted {
                        print("Auto Calibration started")
                        autoCalib()
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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(view: .constant(2))
    }
}
