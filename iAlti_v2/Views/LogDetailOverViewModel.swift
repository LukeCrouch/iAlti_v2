//
//  LogDetailOverViewModel.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 28.12.20.
//

import Foundation
import CoreLocation.CLLocation

class LogDetailOverViewModel: ObservableObject {
    @Published var loaded = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var distance = ""
    @Published var glideRatio: [Double] = []
    @Published var averageGlideRatio = 0.0
    @Published var averageSpeedHorizontal = 0.0
    @Published var averageSpedVertical = 0.0
    
    func load(log: Log) {
        var d: Double = 0
        var i = 0
        for _ in 1..<log.accuracyHorizontal.count {
            let location = CLLocation(latitude: log.latitude[i], longitude: log.longitude[i])
            let locationInit = CLLocation(latitude: log.latitude[0], longitude: log.longitude[0])
            let currentDistance = location.distance(from: locationInit)
            if currentDistance > d { d = currentDistance }
            i += 1
        }
        distance = String(format: "%.2f", d / 1000)
        
        var gr: [Double] = []
        i = 0
        for _ in log.speedHorizontal {
            let glideRatio = log.speedHorizontal[i] / log.speedVertical[i]
            if glideRatio.isNaN {
                gr.append(0)
            } else if glideRatio.isInfinite {
                gr.append(100)
            } else {
                gr.append(glideRatio)
            }
            i += 1
        }
        glideRatio = gr
        
        averageGlideRatio = arithmeticMean(numbers: gr)
        averageSpeedHorizontal = arithmeticMean(numbers: log.speedHorizontal)
        averageSpedVertical = arithmeticMean(numbers: log.speedVertical)
        
        loaded = true
        return
    }
}
