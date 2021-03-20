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
    @State private var selectionAudioPicker: Int = 0
    
    private let displays = ["None", "Glide", "v hor.", "v vert."]
    private let audios = ["None", "Glide", "v hor.", "v vert.", "Altitude", "Variometer"]
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
    private let pickerWidth: CGFloat = 150
    private let pickerHeight: CGFloat = 60
    
    var body: some View {
        ScrollView {
            HStack {
                VStack {
                    TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("QNH [hPa]").font(.footnote)
                }
                VStack {
                    TextField("", value: $userSettings.offset, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .frame(width: 90, height: 50)
                        .font(.system(size: 20))
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Offset [m]").font(.footnote)
                }
            }
            Divider()
            VStack {
                Text("Display 2nd value:")
                Picker("", selection: $selectionDisplayPicker, content: {
                    ForEach(0 ..< displays.count) {index in Text(displays[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
            }.onAppear(perform: {selectionDisplayPicker = userSettings.displaySelection})
            Divider()
            VStack {
                Text("Font Color:")
                Picker("", selection: $selectionColorPicker, content: {
                    ForEach(0 ..< colors.count) {index in Text(colors[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
            }.onAppear(perform: {selectionColorPicker = userSettings.colorSelection})
            Divider()
            VStack {
                Text("Audio Output:")
                Picker("", selection: $selectionAudioPicker, content: {
                    ForEach(0 ..< audios.count) {index in Text(audios[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
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
            }.onAppear(perform: {selectionAudioPicker = userSettings.audioSelection})
        }
        .onChange(of: selectionColorPicker, perform: {_ in userSettings.colorSelection = selectionColorPicker })
        .onChange(of: selectionDisplayPicker, perform: {_ in userSettings.displaySelection = selectionDisplayPicker })
        .onChange(of: selectionAudioPicker, perform: {_ in userSettings.displaySelection = selectionDisplayPicker })
        .onChange(of: userSettings.qnh, perform: {_ in Altimeter.shared.setOffset()})
    }
}
