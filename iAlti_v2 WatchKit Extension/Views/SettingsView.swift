//
//  SettingsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct Weather: Codable {
    var main: Main?
}

struct Main: Codable {
    var pressure: Double?
}


struct SettingsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @State private var results = [Weather]()
    @State private var showingAlert = false
    @State private var selection: Int = 0
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
    func autoCalib() {
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
        VStack {
            HStack {
                VStack {
                    TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("QNH [hPa]")
                }
                VStack {
                    TextField("", value: $userSettings.offset, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Offset [m]")
                }
            }
            HStack {
                VStack {
                    Spacer()
                    Button(action: {
                        if globals.isLocationStarted {
                            print("Auto Calibration started")
                            autoCalib()
                        } else {
                            self.showingAlert = true
                        }
                    }, label: {
                        Image(systemName: "icloud.and.arrow.down")
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .font(.title2)
                    })
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Warning"), message: Text("Start GPS services before calibrating."), dismissButton: .default(Text("OK")))
                    }
                    .frame(width: 90.0, height: 50.0)
                    Text("Calibration")
                }
                VStack {
                    Picker("", selection: $selection, content: {
                        ForEach(0 ..< colors.count) {index in Text(colors[index]).tag(index)}
                    })
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                }
                .onAppear(perform: {selection = userSettings.colorSelection})
                .onDisappear(perform: {userSettings.colorSelection = selection})
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

