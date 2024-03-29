//
//  LogDetailOverView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI
import CoreLocation.CLLocation

struct LogSummaryText: View {
    @ObservedObject private var userSettings = UserSettings.shared
    
    let text: String
    let details: String
    
    var body: some View {
        HStack {
            Text(details)
                .font(.subheadline)
            Spacer()
            Text(text)
                .font(.title)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
        }
    }
}

struct LogSummaryTitle: View {
    @ObservedObject private var userSettings = UserSettings.shared
    
    let text: String
    let details: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.title)
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
            Text(details)
                .font(.subheadline)
                .padding(.bottom)
        }
    }
}

struct LogDetailOverView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @ObservedObject var log: Log
    
    @Binding var glideRatio: [Double]
    
    @ObservedObject var viewModel: LogDetailOverViewModel
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack {
                        LogSummaryTitle(text: dateFormatter.string(from: log.date), details: "Date").padding(.horizontal)
                        LogSummaryTitle(text: log.takeOff, details: "Location").padding(.horizontal)
                        LogSummaryTitle(text: (log.flightTime.asDateString(style: .positional)), details: "Flight Time").padding(.horizontal)
                    }
                    HStack {
                        VStack {
                            TextField("Enter pilot name...", text: $log.pilot)
                                .font(.title)
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }.padding(.horizontal)
                        VStack {
                            TextField("Enter glider...", text: $log.glider)
                                .font(.title)
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }.padding(.horizontal)
                    }
                }
                Divider()
                HStack {
                    Spacer(minLength: 30)
                    VStack {
                        if userSettings.unitSelection == 0 { // metric
                            LogSummaryText(text: viewModel.distance, details: "Distance [km]")
                        } else { // imperial
                            LogSummaryText(text: viewModel.distanceImperial, details: "Distance [miles]")
                        }
                        if userSettings.unitSelection == 0 { // metric
                            LogSummaryText(text: "\(Int(log.altitudeBarometer.max() ?? 0))", details: "Max. barometric Altitude [m]")
                        } else { // imperial
                            LogSummaryText(
                                text: "\(Int(log.altitudeBarometer.max() ?? 0 * 0.000621371))",
                                details: "Max. barometric Altitude [miles]"
                            )
                        }
                        if userSettings.unitSelection == 0 { // metric
                            LogSummaryText(text: "\(Int(log.altitudeGPS.max() ?? 0))", details: "Max. GPS Altitude [m]")
                        } else { // imperial
                            LogSummaryText(
                                text: "\(Int(log.altitudeGPS.max() ?? 0 * 0.000621371))",
                                details: "Max. GPS Altitude [miles]"
                            )
                        }
                        if viewModel.averageGlideRatio > 100 {
                            LogSummaryText(text: "> 100", details: "Average Glide Ratio")
                        } else {
                            LogSummaryText(text: "\(Int(viewModel.averageGlideRatio))", details: "Average Glide Ratio")
                        }
                        if viewModel.glideRatio.max() ?? 0 > 100 {
                            LogSummaryText(text: "> 100", details: "Max. Glide Ratio")
                        } else {
                            LogSummaryText(text: "\(Int(viewModel.glideRatio.max() ?? 0))", details: "Max. Glide Ratio")
                        }
                    }
                    Spacer(minLength: 100)
                    VStack {
                        if userSettings.unitSelection == 0 { // metric
                            LogSummaryText(text: "\(Int(viewModel.averageSpeedHorizontal * 3.6))", details: "Average horizontal Speed [km/h]")
                            LogSummaryText(text: "\(Int((log.speedHorizontal.max() ?? 0) * 3.6))", details: "Max. horizontal Speed [km/h]")
                            LogSummaryText(text: "\(Int(viewModel.averageSpedVertical * 3.6))", details: "Average vertical Speed [km/h]")
                            LogSummaryText(text: "\(Int((log.speedVertical.max() ?? 0) * 3.6))", details: "Max. vertical Speed [km/h]")
                        } else { // imperial
                            LogSummaryText(text: "\(Int(viewModel.averageSpeedHorizontal * 2.23694))", details: "Average horizontal Speed [mph]")
                            LogSummaryText(text: "\(Int((log.speedHorizontal.max() ?? 0) * 2.23694))", details: "Max. horizontal Speed [mph]")
                            LogSummaryText(text: "\(Int(viewModel.averageSpedVertical * 2.23694))", details: "Average vertical Speed [mph]")
                            LogSummaryText(text: "\(Int((log.speedVertical.max() ?? 0) * 2.23694))", details: "Max. vertical Speed [mph]")
                        }
                    }
                    Spacer(minLength: 30)
                }
            }
        }.onAppear(perform: {
            glideRatio = viewModel.glideRatio
        })
    }
}
