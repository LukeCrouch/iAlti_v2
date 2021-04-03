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
    @State private var selectionLanguagePicker: Int = 0
    
    private let displays = ["None", "Glide", "v hor.", "v vert."]
    private let audios = ["None", "Glide", "v hor.", "v vert.", "Altitude", "Variometer"]
    private let colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
    private let pickerWidth: CGFloat = 150
    private let pickerHeight: CGFloat = 50
    
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
                Picker("", selection: $selectionDisplayPicker, content: {
                    ForEach(0 ..< displays.count) {index in Text(displays[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Display 2nd value")
                Divider()
                Picker("", selection: $selectionColorPicker, content: {
                    ForEach(0 ..< colors.count) {index in Text(colors[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Font Color")
                Divider()
            }
            VStack {
                Picker("", selection: $selectionAudioPicker, content: {
                    ForEach(0 ..< audios.count) {index in Text(audios[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Audio Output")
                if userSettings.audioSelection != 0 {
                    if userSettings.audioSelection != 5 {
                        Picker("", selection: $selectionLanguagePicker, content: {
                            ForEach(0 ..< userSettings.voiceLanguages.count) {
                                let text = (userSettings.voiceLanguages[$0]["languageName"] ?? "Unknown") + " " + (userSettings.voiceLanguages[$0]["voiceName"] ?? "")
                                Text(text).foregroundColor(userSettings.colors[userSettings.colorSelection])
                            }
                        })
                        .frame(width: pickerWidth, height: pickerHeight)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Audio Language")
                    }
                    Button(action: {
                        let cachedSelection = userSettings.audioSelection
                        userSettings.audioSelection = 1
                        testAudio()
                        userSettings.audioSelection = cachedSelection
                    },
                    label: {
                        HStack {
                            Image(systemName: "speaker.wave.3")
                            Text("Test voice ouput")}
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    })
                }
            }
        }
        .onAppear(perform: {
            selectionColorPicker = userSettings.colorSelection
            selectionLanguagePicker = userSettings.voiceLanguageSelection
            selectionDisplayPicker = userSettings.displaySelection
            selectionAudioPicker = userSettings.audioSelection
        })
        .onChange(of: selectionColorPicker, perform: {sel in userSettings.colorSelection = sel })
        .onChange(of: selectionDisplayPicker, perform: {sel in userSettings.displaySelection = sel })
        .onChange(of: selectionAudioPicker, perform: {sel in userSettings.audioSelection = sel })
        .onChange(of: selectionLanguagePicker, perform: {sel in userSettings.voiceLanguageSelection = sel })
        .onChange(of: userSettings.qnh, perform: {_ in Altimeter.shared.setOffset()})
    }
}
