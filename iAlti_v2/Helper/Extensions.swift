//
//  Extensions.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 09.12.20.
//

import Foundation

public extension String {
    var model: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }
}

public extension Double {
    func asDateString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}

public func arithmeticMean(numbers: [Double]) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
