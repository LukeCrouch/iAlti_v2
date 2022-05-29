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
    
    private let displays = ["None", "Glide", "Speed horiz.", "Speed vertical"] //If this is changed, also change the For Each Loops
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
                    ForEach(0 ..< 4) {index in Text(displays[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Display 2nd value")
                Divider()
                Picker("", selection: $selectionColorPicker, content: {
                    ForEach(0 ..< 4) {index in Text(colors[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Font Color")
                Divider()
            }
        }
        .onAppear(perform: {
            selectionColorPicker = userSettings.colorSelection
            selectionDisplayPicker = userSettings.displaySelection
        })
        .onChange(of: selectionColorPicker, perform: {sel in userSettings.colorSelection = sel })
        .onChange(of: selectionDisplayPicker, perform: {sel in userSettings.displaySelection = sel })
        .onChange(of: userSettings.qnh, perform: {_ in Altimeter.shared.setOffset()})
    }
}
