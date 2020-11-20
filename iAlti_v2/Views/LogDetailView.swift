//
//  LogDetailView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//

import SwiftUI

struct LogSummaryText: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    let text: String
    let details: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
            Text(details)
                .font(.caption)
        }
    }
}

struct LogDetailView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var log: Log
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        TabView {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        TextField("\(log.pilot)", text: $log.pilot)
                            .font(.headline)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Pilot")
                            .font(.caption)
                    }.padding(.bottom)
                    Spacer()
                    VStack {
                        TextField("\(log.glider)", text: $log.glider)
                            .font(.headline)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Glider")
                            .font(.caption)
                    }
                    Spacer()
                }
                HStack {
                    VStack {
                        Text("\(log.date, formatter: formatter)")
                            .font(.headline)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Date")
                            .font(.caption)
                    }
                    LogSummaryText(text: "\(log.takeoff)", details: "Take Off")
                    VStack {
                        Text(log.flightTime.asString(style: .positional))
                            .font(.headline)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        Text("Flight Time")
                            .font(.caption)
                    }
                    LogSummaryText(text: "\(Int(log.maxAltitude))", details: "Max. Altitude [m MSL]")
                    LogSummaryText(text: "\(Int(log.distance))", details: "Distance [km]")
                }
                Spacer()
            }
        }
    }
}


struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(log: Log())
    }
}
