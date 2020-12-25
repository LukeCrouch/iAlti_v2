//
//  SettingsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @State private var selectionColorPicker: Int = 0
    @State private var selectionDisplayPicker: Int = 0
    
    private let displays = ["None", "Glide Ratio", "Speed Hor.", "Speed Vert."]
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
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
                    Picker("", selection: $selectionDisplayPicker, content: {
                        ForEach(0 ..< displays.count) {index in Text(displays[index]).tag(index)}
                    }).foregroundColor(userSettings.colors[userSettings.colorSelection])
                }.onAppear(perform: {selectionDisplayPicker = userSettings.displaySelection})
                VStack {
                    Picker("", selection: $selectionColorPicker, content: {
                        ForEach(0 ..< colors.count) {index in Text(colors[index]).tag(index)}
                    }).foregroundColor(userSettings.colors[userSettings.colorSelection])
                }.onAppear(perform: {selectionColorPicker = userSettings.colorSelection})
            }
        }
        .onChange(of: selectionColorPicker, perform: {_ in userSettings.colorSelection = selectionColorPicker })
        .onChange(of: selectionDisplayPicker, perform: {_ in userSettings.displaySelection = selectionDisplayPicker })
        .onChange(of: userSettings.qnh, perform: {_ in Altimeter.shared.setOffset()})
    }
}
