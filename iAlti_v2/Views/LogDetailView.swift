//
//  LogDetailView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//

import SwiftUI

struct LogDetailView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var log: Log
    
    var body: some View {
        TabView {
            LogDetailOverView(log: log)
                .tabItem {}
                .tag(0)
            LogDetailGraphView(log: log)
                .tabItem {}
                .tag(1)
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}


struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(log: Log())
    }
}
