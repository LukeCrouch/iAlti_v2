//
//  LogDetailOverView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI

struct LogSummaryText: View {
    let text: String
    let details: String
    
    var body: some View {
        HStack {
            Text(details)
                .font(.subheadline)
            Spacer()
            Text(text)
                .font(.title)
                .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
        }
    }
}

struct LogSummaryTitle: View {
    @EnvironmentObject var userSettings: UserSettings
    
    let text: String
    let details: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.title)
                .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
            Text(details)
                .font(.subheadline)
                .padding(.bottom)
        }
    }
}

struct LogDetailOverView: View {
    @ObservedObject var log: Log
    
    private var averageGlideRatio: Double {
        return arithmeticMean(numbers: log.glideRatio)
    }
    
    private var averageSpeedHorizontal: Double {
        return arithmeticMean(numbers: log.speedHorizontal)
    }
    
    private var averageSpedVertical: Double {
        return arithmeticMean(numbers: log.speedVertical)
    }
    
    private var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let formattedDate = formatter.string(from: log.date)
        return formattedDate
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    LogSummaryTitle(text: stringDate, details: "Date").padding(.horizontal)
                    LogSummaryTitle(text: "\(log.takeOff)", details: "Take Off").padding(.horizontal)
                    LogSummaryTitle(text: log.flightTime.asString(style: .positional), details: "Flight Time").padding(.horizontal)
                }
                HStack {
                    VStack {
                        TextField("Enter pilot name...", text: $log.pilot)
                            .font(.title)
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }.padding(.all)
                    VStack {
                        TextField("Enter glider...", text: $log.glider)
                            .font(.title)
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }.padding(.all)
                }
            }
            Divider()
            HStack {
                Spacer(minLength: 30)
                VStack {
                    LogSummaryText(text: "\(Int(log.distance / 1000))", details: "Distance [km]")
                    LogSummaryText(text: "\(Int(log.altitude.max() ?? 0))", details: "Max. Altitude [m MSL]")
                    LogSummaryText(text: "\(Int(averageGlideRatio))", details: "Average Glide Ratio")
                    LogSummaryText(text: "\(Int(log.glideRatio.max() ?? 0))", details: "Max. Glide Ratio")
                }
                Spacer(minLength: 100)
                VStack {
                    LogSummaryText(text: "\(Int(averageSpeedHorizontal))", details: "Average horizontal Speed [km/h]")
                    LogSummaryText(text: "\(Int(log.speedHorizontal.max() ?? 0))", details: "Max. horizontal Speed [km/h]")
                    LogSummaryText(text: "\(Int(averageSpedVertical))", details: "Average vertical Speed [km/h]")
                    LogSummaryText(text: "\(Int(log.speedVertical.max() ?? 0))", details: "Max. vertical Speed [km/h]")
                }
                Spacer(minLength: 30)
            }
        }
    }
}

struct LogDetailOverView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailOverView(log: Log())
    }
}
