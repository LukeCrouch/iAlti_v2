//
//  SettingsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var showingAlert = false
    @State private var selection: Int = 0
    
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    Text("QNH [hPa]")
                }
                VStack {
                    TextField("", value: $userSettings.offset, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                    Text("Offset [m]")
                }
            }
            HStack {
                VStack {
                    Spacer()
                    Button(action: {
                        if LocationManager.shared.isLocationStarted {
                            debugPrint("Auto Calibration started")
                            LocationManager.shared.autoCalib()
                        } else {
                            self.showingAlert = true
                        }
                    }, label: {
                        Image(systemName: "icloud.and.arrow.down")
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
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
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                }
                .onAppear(perform: {selection = UserSettings.shared.colorSelection})
                .onDisappear(perform: {UserSettings.shared.colorSelection = selection})
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

