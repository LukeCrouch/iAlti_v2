//
//  ContentView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewSelection: ViewSelection
    
    var body: some View {
        TabView(selection: $viewSelection.view) {
            MainView()
                .tabItem {Image(systemName: "location")}
                .tag(0)
            NavigationView { LogView()
                .toolbar(content: { ToolbarItem(placement: .principal, content: { Text("Logs") } ) } ) }
            .tabItem {Image(systemName: "list.dash")}
            .tag(1)
            NavigationView { SettingsView()
                .toolbar(content: {
                            ToolbarItem(placement: .principal, content: { Text("Settings") } ) } ) }
                .tabItem {Image(systemName: "gearshape")}
                .tag(2)
        }
    }
}
