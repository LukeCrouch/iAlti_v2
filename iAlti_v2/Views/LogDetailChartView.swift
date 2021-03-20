//
//  LogDetailChartView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.03.21.
//

import UIKit
import SwiftCharts
import SwiftUI

struct LogDetailChartView: UIViewControllerRepresentable {
    var glideRatio: [Double]
    var log:Log
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> ChartController {
        let chartController = ChartController()
        chartController.glideRatio = glideRatio
        chartController.log = log
        return chartController
    }
    
    func updateUIViewController(_ uiViewController: ChartController, context: Context) { }
}

class ChartController: UIViewController {
    var glideRatio: [Double] = []
    var log = Log()
    
    fileprivate var chart: Chart?
    
    let bgColors = [UIColor.red, UIColor(red: 0, green: 0.7, blue: 1, alpha: 1), UIColor(red: 0, green: 0.7, blue: 0, alpha: 1), UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)]
    
    fileprivate let labelFont: UIFont
    fileprivate let labelFontSmall: UIFont = UIFont(name: "Helvetica", size: 10) ?? UIFont.systemFont(ofSize: 10)
    fileprivate let labelSettings: ChartLabelSettings
    
    fileprivate var showGuides: Bool = false
    fileprivate var selectedLayersFlags = [true, true, true, true]
    
    fileprivate var chartPoints0: [ChartPoint] = []
    fileprivate var chartPoints1: [ChartPoint] = []
    fileprivate var chartPoints2: [ChartPoint] = []
    fileprivate var chartPoints3: [ChartPoint] = []
    
    fileprivate var viewFrame: CGRect!
    fileprivate var chartInnerFrame: CGRect!
    
    fileprivate var yLowAxesLayers: [ChartAxisLayer]!
    fileprivate var yHighAxesLayers: [ChartAxisLayer]!
    fileprivate var xLowAxesLayers: [ChartAxisLayer]!
    fileprivate var xHighAxesLayers: [ChartAxisLayer]!
    
    fileprivate var guideLinesLayer0: ChartLayer!
    fileprivate var guideLinesLayer1: ChartLayer!
    fileprivate var guideLinesLayer2: ChartLayer!
    fileprivate var guideLinesLayer3: ChartLayer!
    
    fileprivate let selectionViewH: CGFloat = 100
    fileprivate let showGuidesViewH: CGFloat = 50

    init() {
        labelFont = UIFont(name: "Helvetica", size: 11) ?? UIFont.systemFont(ofSize: 11)
        labelSettings = ChartLabelSettings(font: labelFont)
        
        super.init(nibName: nil, bundle: nil)
        
        func createChartPoint(x: Double, y: Double, labelColor: UIColor) -> ChartPoint {
            return ChartPoint(x: ChartAxisValueDouble(x, labelSettings: labelSettings), y: ChartAxisValueDouble(y, labelSettings: labelSettings))
        }
        
        func createChartPoints0(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(x: 0, y: 0, labelColor: color),
                createChartPoint(x: 2, y: 2, labelColor: color)
            ]
        }
        
        chartPoints0 = createChartPoints0(bgColors[0])
        chartPoints1 = chartPoints0
        chartPoints2 = chartPoints0
        chartPoints3 = chartPoints0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 0
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    private var iPhoneChartSettingsWithPan: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = false
        return chartSettings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func createChartPoints(_ color: UIColor, data: [Double]) -> [ChartPoint] {
            var points: [ChartPoint] = []
            
            let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                return formatter
            }()
            var timestamps: [Double] {
                let zero = dateFormatter.date(from: log.timestamps[0])!
                var timestamps: [Double] = []
                for tString in log.timestamps {
                    let tDate = dateFormatter.date(from: tString)!
                    let diff = Calendar.current.dateComponents([.second], from: zero, to: tDate)
                    timestamps.append(Double(diff.second!))
                }
                return timestamps
            }
            
            for i in 0...(data.count - 1) {
                points.append(createChartPoint(x: timestamps[i], y: data[i], labelColor: color))
            }
            return points
        }
        
        func createChartPoint(x: Double, y: Double, labelColor: UIColor) -> ChartPoint {
            return ChartPoint(x: ChartAxisValueDouble(x, labelSettings: labelSettings), y: ChartAxisValueDouble(y, labelSettings: labelSettings))
        }
        
        chartPoints0 = createChartPoints(bgColors[0], data: glideRatio)
        chartPoints1 = createChartPoints(bgColors[1], data: log.altitudeBarometer)
        chartPoints2 = createChartPoints(bgColors[2], data: log.speedVertical)
        chartPoints3 = createChartPoints(bgColors[3], data: log.speedHorizontal)
        
        
        let xValues0 = chartPoints0.map{$0.x}
        let xValues1 = chartPoints1.map{$0.x}
        let xValues2 = chartPoints2.map{$0.x}
        let xValues3 = chartPoints3.map{$0.x}
        
        let chartSettings = iPhoneChartSettingsWithPan
        
        viewFrame = CGRect(x: 0, y: 20, width: view.frame.size.width, height: view.frame.size.height - 50)
        
        let yValues0 = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints0, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: labelFontSmall, fontColor: bgColors[0]))}, addPaddingSegmentIfEdge: false)
        
        let yValues1 = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints1, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: labelFontSmall, fontColor: bgColors[1]))}, addPaddingSegmentIfEdge: false)
        
        let yValues2 = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints2, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: labelFontSmall, fontColor: bgColors[2]))}, addPaddingSegmentIfEdge: false)
        
        let yValues3 = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints3, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: labelFontSmall, fontColor: bgColors[3]))}, addPaddingSegmentIfEdge: false)
        
        let axisTitleFont = labelFontSmall
        
        let yLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues1, lineColor: bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Altitude", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[1]).defaultVertical())]),
            ChartAxisModel(axisValues: yValues0, lineColor: bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Glide Ratio", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[0]).defaultVertical())])
        ]
        let yHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues2, lineColor: bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Speed Horizontal [m/s]", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[2]).defaultVertical())]),
            ChartAxisModel(axisValues: yValues3, lineColor: bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Speed Vertical [m/s]", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[3]).defaultVertical())])
        ]
        let xLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues0, lineColor: bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Flight Time", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[0]))]),
            ChartAxisModel(axisValues: xValues1, lineColor: bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "2", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[1]))])
        ]
        let xHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues3, lineColor: bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "3", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[3]))]),
            ChartAxisModel(axisValues: xValues2, lineColor: bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "4", settings: ChartLabelSettings(font: axisTitleFont, fontColor: bgColors[2]))])
        ]
        
        // calculate coords space in the background to keep UI smooth
        DispatchQueue.global(qos: .background).async {
            
            let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: self.viewFrame.size, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels)
            
            DispatchQueue.main.async {
                
                self.chartInnerFrame = coordsSpace.chartInnerFrame
                
                // create axes
                self.yLowAxesLayers = coordsSpace.yLowAxesLayers
                self.yHighAxesLayers = coordsSpace.yHighAxesLayers
                self.xLowAxesLayers = coordsSpace.xLowAxesLayers
                self.xHighAxesLayers = coordsSpace.xHighAxesLayers
                
                let guidelinesWidth: CGFloat = 0.1
                
                // create layers with references to axes
                let guideLinesLayer0Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[0], linesWidth: guidelinesWidth)
                self.guideLinesLayer0 = ChartGuideLinesDottedLayer(xAxisLayer: self.xLowAxesLayers[0], yAxisLayer: self.yLowAxesLayers[1], settings: guideLinesLayer0Settings)
                let guideLinesLayer1Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[1], linesWidth: guidelinesWidth)
                self.guideLinesLayer1 = ChartGuideLinesDottedLayer(xAxisLayer: self.xLowAxesLayers[1], yAxisLayer: self.yLowAxesLayers[0], settings: guideLinesLayer1Settings)
                let guideLinesLayer3Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[2], linesWidth: guidelinesWidth)
                self.guideLinesLayer2 = ChartGuideLinesDottedLayer(xAxisLayer: self.xHighAxesLayers[1], yAxisLayer: self.yHighAxesLayers[0], settings: guideLinesLayer3Settings)
                let guideLinesLayer4Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[3], linesWidth: guidelinesWidth)
                self.guideLinesLayer3 = ChartGuideLinesDottedLayer(xAxisLayer: self.xHighAxesLayers[0], yAxisLayer: self.yHighAxesLayers[1], settings: guideLinesLayer4Settings)
                
                self.showChart(chartSettings, lineAnimDuration: 1)
            }
        }
    }
    
    fileprivate func createLineLayers(animDuration: Float) -> [ChartPointsLineLayer<ChartPoint>] {
        let lineModel0 = ChartLineModel(chartPoints: chartPoints0, lineColor: bgColors[0], animDuration: animDuration, animDelay: 0)
        let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: bgColors[1], animDuration: animDuration, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: bgColors[2], animDuration: animDuration, animDelay: 0)
        let lineModel3 = ChartLineModel(chartPoints: chartPoints3, lineColor: bgColors[3], animDuration: animDuration, animDelay: 0)
        
        let chartPointsLineLayer0 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxesLayers[0].axis, yAxis: yLowAxesLayers[1].axis, lineModels: [lineModel0])
        let chartPointsLineLayer1 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxesLayers[1].axis, yAxis: yLowAxesLayers[0].axis, lineModels: [lineModel1])
        let chartPointsLineLayer2 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxesLayers[1].axis, yAxis: yHighAxesLayers[0].axis, lineModels: [lineModel2])
        let chartPointsLineLayer3 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxesLayers[0].axis, yAxis: yHighAxesLayers[1].axis, lineModels: [lineModel3])
        
        return [chartPointsLineLayer0, chartPointsLineLayer1, chartPointsLineLayer2, chartPointsLineLayer3]
    }
    
    
    fileprivate func createLayers(selectedLayersFlags: [Bool], showGuides: Bool, lineAnimDuration: Float) -> ([ChartLayer]) {
        let lineLayers = createLineLayers(animDuration: lineAnimDuration)
        
        func group(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, lineLayer: ChartLayer, guideLayer: ChartLayer) -> [ChartLayer] {
            return [xAxis, yAxis, lineLayer] + (showGuides ? [guideLayer] : [])
        }
        
        let layers: [[ChartLayer]] = [
            group(xAxis: xLowAxesLayers[0], yAxis: yLowAxesLayers[1], lineLayer: lineLayers[0], guideLayer: guideLinesLayer0),
            group(xAxis: xLowAxesLayers[0], yAxis: yLowAxesLayers[0], lineLayer: lineLayers[1], guideLayer: guideLinesLayer1),
            group(xAxis: xLowAxesLayers[0], yAxis: yHighAxesLayers[0], lineLayer: lineLayers[2], guideLayer: guideLinesLayer2),
            group(xAxis: xLowAxesLayers[0], yAxis: yHighAxesLayers[1], lineLayer: lineLayers[3], guideLayer: guideLinesLayer3)
        ]
        
        return selectedLayersFlags.enumerated().reduce(Array<ChartLayer>()) {selectedLayers, inTuple in
            
            let index = inTuple.0
            let selected = inTuple.1
            
            if selected {
                return selectedLayers + layers[index]
            }
            return selectedLayers
        }
    }
    
    fileprivate func showChart(_ chartSettings: ChartSettings, lineAnimDuration: Float) -> () {
        
        self.chart?.clearView()
        
        let layers = createLayers(selectedLayersFlags: selectedLayersFlags, showGuides: showGuides, lineAnimDuration: lineAnimDuration)
        
        let view = ChartBaseView(frame: viewFrame)
        let chart = Chart(
            view: view,
            innerFrame: chartInnerFrame,
            settings: chartSettings,
            layers: layers
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
        
        chartInnerFrame = chart.containerView.frame
    }
}
