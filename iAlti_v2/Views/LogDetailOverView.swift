//
//  LogDetailOverView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
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
                .font(.title)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
            Text(details)
                .font(.headline)
        }
    }
}

struct LogDetailOverView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var log: Log
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("\(log.date, formatter: formatter)")
                        .font(.title2)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Date")
                        .font(.subheadline)
                }.padding(.horizontal)
                LogSummaryText(text: "\(log.takeoff)", details: "Take Off").padding(.horizontal)
                VStack {
                    Text(log.flightTime.asString(style: .positional))
                        .font(.title2)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    Text("Flight Time")
                        .font(.subheadline)
                }.padding(.horizontal)
                }
            Divider().padding(.bottom)
            HStack {
                VStack {
                    TextField("Enter pilot name...", text: $log.pilot)
                        .font(.title)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Text("Pilot")
                        .font(.headline)
                }
                VStack {
                    TextField("Enter glider...", text: $log.glider)
                        .font(.title)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Text("Glider")
                        .font(.subheadline)
                }
            }
            Divider()
            HStack {
                LogSummaryText(text: "\(Int(log.maxAltitude))", details: "Max. Altitude [m MSL]").padding(.horizontal)
                LogSummaryText(text: "\(Int(log.distance))", details: "Distance [km]").padding(.horizontal)
                LogSummaryText(text: "\(Int(log.speedAvg))", details: "Average Speed [km/h]")
            }
        }
    }
}

struct LogDetailOverView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailOverView(log: Log())
    }
}
