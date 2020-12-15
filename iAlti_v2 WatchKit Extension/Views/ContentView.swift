//
//  ContentView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ContentView: View {
    @State var view = 0

    var body: some View {
        TabView(selection: $view) {
            ControlsView(view: $view)
            .tabItem {}
                .tag(1)
            MainView()
                .tabItem {}
                .tag(0)
            OverView()
                .tabItem {}
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}
