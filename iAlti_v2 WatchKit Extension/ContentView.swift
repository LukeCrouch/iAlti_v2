//
//  ContentView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @State var view = 0

    var body: some View {
        
        TabView(selection: $view) {
            ControlsView(view: $view)
                .environmentObject(globals)
                .environmentObject(userSettings)
            .tabItem {
                Text("Controls")
            }.tag(1)
            MainView()
                .environmentObject(globals)
                .environmentObject(userSettings)
                .tabItem {
                    Text("Main")
                }.tag(0)
            OverView()
                .environmentObject(globals)
                .environmentObject(userSettings)
                .tabItem {
                    Text("Overview")
                }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
            .environmentObject(Globals())
    }
    
}
