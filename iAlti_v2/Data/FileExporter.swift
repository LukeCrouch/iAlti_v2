//
//  FileExporter.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 24.12.20.
//

import SwiftUI
import CoreGPX
import CoreLocation.CLLocation

class FileExporter: NSObject {
    
    class var FilesFolderURL: URL {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl
    }
    
    /// Export a Log to a chosen file type and share it via iOS ShareSheet
    ///
    /// - Parameters:
    ///     - log: CoreData Entitiy Log that contains all details about one saved flight.
    ///     - fileContents: The content of the file to be exported.
    ///     - fileType: GPX or CSV.
    /// - Returns:
    ///     A `Bool`
    ///
    @discardableResult
    class func share(log: Log, fileType: String, excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        
        let dateFormatterShort: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
        
        var fileContents = ""
        if fileType == "gpx" {
            fileContents = writeXML(log: log)
        } else {
            fileContents = writeCSV(log: log)
        }
        let filename = dateFormatterShort.string(from: log.date) + "_\(log.takeOff)"
        let exportURL = save(filename, fileContents: fileContents, fileType: fileType)
        
        let vc = UIActivityViewController(
            activityItems: [exportURL],
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
    
    class func save(_ filename: String, fileContents: String, fileType: String) -> URL {
        //check if name exists
        let fileURL: URL = URLForFilename(filename, fileType: fileType)
        saveToURL(fileURL, fileContents: fileContents)
        return fileURL
    }
    
    class func URLForFilename(_ filename: String, fileType: String) -> URL {
        var fullURL = FilesFolderURL.appendingPathComponent(filename)
        fullURL = fullURL.appendingPathExtension(fileType)
        return fullURL
    }
    
    /// Write a CSV string
    ///
    /// - Parameters:
    ///     - log: CoreData Entitiy Log that contains all details about one saved flight.
    /// - Returns:
    ///     A `String` that can be saved to a file.
    ///
    class func writeCSV(log: Log) -> String {
        var csv: String = "time,lat,lon,hMSL,velN,velE,velD,hAcc,vAcc,sAcc,gpsFix,numSV\n,(deg),(deg),(m),(m/s),(m/s),(m/s),(m),(m),(m/s),,,"
        
        var i = 0
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.00ZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        let dateFormatterFromLog: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        for _ in log.accuracyHorizontal {
            let velN = cos(log.course[i]) * log.accuracyHorizontal[i]
            let velE = sin(log.course[i]) * log.accuracyHorizontal[i]
            let timestampString = dateFormatter.string(from: dateFormatterFromLog.date(from: log.timestamps[i])!)
            
            csv.append("\n" + timestampString + "," + String(format: "%.7f", log.latitude[i]) + ",")
            csv.append(String(format: "%.7f", log.longitude[i]) + "," + String(format: "%.3f", log.altitudeGPS[i]))
            csv.append("," + String(format: "%.2f", velN) + "," + String(format: "%.2f", velE) + ",")
            csv.append(String(format: "%.2f", log.speedVertical[i]) + ",\(log.accuracyHorizontal[i]),\(log.accuracyVertical[i])")
            csv.append(",0,3,1")
            i += 1
        }
        
        debugPrint("Writing CSV file with \(i) entries.")
        return csv
    }
    
    /// Write a XML string according to GPX standard
    ///
    /// - Parameters:
    ///     - log: CoreData Entitiy Log that contains all details about one saved flight.
    /// - Returns:
    ///     A `String` that can be saved to a file.
    ///
    class func writeXML(log: Log) -> String {
        let root = GPXRoot(creator: "iAlti")
        let metadata = GPXMetadata()
        metadata.name = log.pilot
        metadata.time = Date()
        root.metadata = metadata
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
        
        var trackpoints = [GPXTrackPoint]()
        var i = 0
        
        for _ in log.altitudeBarometer {
            let trackpoint = GPXTrackPoint(latitude: log.latitude[i], longitude: log.longitude[i])
            trackpoint.elevation = log.altitudeGPS[i]
            trackpoint.time = dateFormatter.date(from: log.timestamps[i])
            trackpoint.horizontalDilution = log.accuracyHorizontal[i]
            trackpoint.verticalDilution = log.accuracyVertical[i]
            trackpoints.append(trackpoint)
            i += 1
        }
        
        let track = GPXTrack()                          // inits a track
        let tracksegment = GPXTrackSegment()            // inits a tracksegment
        tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
        track.add(trackSegment: tracksegment)           // adds a track segment to a track
        root.add(track: track)                          // adds a track
        
        debugPrint("Writing XML file with \(i) entries.")
        return root.gpx()
    }
    
    class func saveToURL(_ fileURL: URL, fileContents: String) {
        do {
            try fileContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            debugPrint("Saved file to: \(fileURL)")
        } catch let error as NSError {
            debugPrint("Error saving file to URL: \(error.localizedDescription)")
        }
        
    }
}
