//
//  LogDetailGraphView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 20.11.20.
//

import SwiftUI

struct LogDetailGraphView: View {
    @ObservedObject var log: Log
    
    var body: some View {
        VStack {
            Text("Graph goes here")
            //LineChartView(data: [8,23,54,32,12,37,7,23,43], title: "Title")
        }
    }
}


struct LogDetailGraphView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailGraphView(log: Log())
    }
}
