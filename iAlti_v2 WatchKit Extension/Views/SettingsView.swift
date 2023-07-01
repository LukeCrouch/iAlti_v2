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
    private let unitSystems = ["Metric", "Imperial"]

    
    private let pickerWidth: CGFloat = 150
    private let pickerHeight: CGFloat = 50
    
    
    var body: some View {
        ScrollView {
            HStack {
                VStack {
                    if userSettings.unitSelection == 0 { // metric
                        TextField("", value: $userSettings.qnh, formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 90, height: 50)
                            .font(.system(size: 20))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("QNH [hPa]").font(.footnote)
                    } else { // imperial
                        TextField("", value: $userSettings.qnhImperial, formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 90, height: 50)
                            .font(.system(size: 20))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("QNH [psf]").font(.footnote)
                    }
                }
                VStack {
                    if userSettings.unitSelection == 0 { // metric
                        TextField("", value: $userSettings.offset, formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 90, height: 50)
                            .font(.system(size: 20))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Offset [m]").font(.footnote)
                    } else { // imperial
                        TextField("", value: $userSettings.offsetImperial, formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .frame(width: 90, height: 50)
                            .font(.system(size: 20))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Offset [feet]").font(.footnote)
                    }
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
                Picker("", selection: $userSettings.unitSelection, content: {
                    ForEach(0 ..< 2) {index in Text(unitSystems[index]).tag(index)}
                })
                .frame(width: pickerWidth, height: pickerHeight)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Text("Unit System")
                Divider()
            }
        }
        .onAppear(perform: {
            selectionColorPicker = userSettings.colorSelection
            selectionDisplayPicker = userSettings.displaySelection
        })
        .onChange(of: selectionColorPicker, perform: {sel in userSettings.colorSelection = sel })
        .onChange(of: selectionDisplayPicker, perform: {sel in userSettings.displaySelection = sel })
        .onChange(of: userSettings.qnh, perform: {_ in
            userSettings.qnhImperial = userSettings.qnh * 2.0885434
            Altimeter.shared.setOffset()
        })
        .onChange(of: userSettings.qnhImperial, perform : {_ in userSettings.qnh = userSettings.qnhImperial / 2.0885434})
        .onChange(of: userSettings.offsetImperial, perform: {_ in userSettings.offset = userSettings.offsetImperial / 3.28084 })
        .onChange(of: userSettings.offset, perform: {_ in userSettings.offsetImperial = userSettings.offset * 3.28084 })
    }
}

 
            
