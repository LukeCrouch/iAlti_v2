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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private var distance: String {
        var temp: Double = 0
        var i = 0
        if log.accuracyHorizontal.count > 3 {
            for _ in 1..<log.accuracyHorizontal.count {
                let location = CLLocation(latitude: log.latitude[i], longitude: log.longitude[i])
                let locationInit = CLLocation(latitude: log.latitude[0], longitude: log.longitude[0])
                let currentDistance = location.distance(from: locationInit)
                if currentDistance > temp { temp = currentDistance }
                i += 1
            }
        }
        return String(format: "%.2f", temp / 1000)
    }
    
    private var glideRatio: [Double] {
        var temp: [Double] = []
        var i = 0
        for _ in log.speedHorizontal {
            let glideRatio = log.speedHorizontal[i] / log.speedVertical[i]
            if glideRatio.isNaN {
                temp.append(0)
            } else if glideRatio.isInfinite {
                temp.append(100)
            } else {
                temp.append(glideRatio)
            }
            i += 1
        }
        return temp
    }
    
    private var averageGlideRatio: Double {
        return arithmeticMean(numbers: glideRatio)
    }
    
    private var averageSpeedHorizontal: Double {
        return arithmeticMean(numbers: log.speedHorizontal)
    }
    
    private var averageSpedVertical: Double {
        return arithmeticMean(numbers: log.speedVertical)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    LogSummaryTitle(text: dateFormatter.string(from: log.date), details: "Date").padding(.horizontal)
                    LogSummaryTitle(text: log.takeOff, details: "Take Off").padding(.horizontal)
                    LogSummaryTitle(text: (log.flightTime.asString(style: .positional)), details: "Flight Time").padding(.horizontal)
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
                    LogSummaryText(text: distance, details: "Distance [km]")
                    LogSummaryText(text: "\(Int(log.altitudeBarometer.max() ?? 0))", details: "Max. barometric Altitude MSL [m]")
                    LogSummaryText(text: "\(Int(log.altitudeGPS.max() ?? 0))", details: "Max. GPS Altitude MSL [m]")
                    LogSummaryText(text: "\(Int(averageGlideRatio))", details: "Average Glide Ratio")
                    LogSummaryText(text: "\(Int(glideRatio.max() ?? 0))", details: "Max. Glide Ratio")
                }
                Spacer(minLength: 100)
                VStack {
                    LogSummaryText(text: "\(Int(averageSpeedHorizontal * 3.6))", details: "Average horizontal Speed [km/h]")
                    LogSummaryText(text: "\(Int((log.speedHorizontal.max() ?? 0) * 3.6))", details: "Max. horizontal Speed [km/h]")
                    LogSummaryText(text: "\(Int(averageSpedVertical * 3.6))", details: "Average vertical Speed [km/h]")
                    LogSummaryText(text: "\(Int((log.speedVertical.max() ?? 0) * 3.6))", details: "Max. vertical Speed [km/h]")
                }
                Spacer(minLength: 30)
            }
        }
    }
}
