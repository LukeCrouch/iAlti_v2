//
//  LogDeteailGraphView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI

struct LogDeteailGraphView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var log: Log
    
    var body: some View {
        /*LineChartView(xValues: [0, log.altitude.count],
                      yValues: log.altitude,
                      fillStyle: viewModel.chartFillStyle,
                      filter: LowPassFilter(initialValue: viewModel.speed.first, factor: 0.2),
                      unit: UnitSpeed.metersPerSecond,
                      outUnit: Settings.shared.speedUnit)*/
        Text("Hello World!")
    }
}

struct LogDeteailGraphView_Previews: PreviewProvider {
    static var previews: some View {
        LogDeteailGraphView(log: Log())
    }
}
