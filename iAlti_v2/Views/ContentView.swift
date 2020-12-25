//
//  ContentView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ContentView: View {
    @State var view = 2
    
    var body: some View {
        TabView(selection: $view) {
            MainView()
                .tabItem {Image(systemName: "location")}
                .tag(0)
            NavigationView { LogView().navigationTitle("Logs") }
                .tabItem {Image(systemName: "list.dash")}
                .tag(1)
            NavigationView { SettingsView(view: $view).navigationTitle("Settings") }
                .tabItem {Image(systemName: "gearshape")}
                .tag(2)
        }
    }
}
