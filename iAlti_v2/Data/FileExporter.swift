//
//  FileExporter.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 24.12.20.
//

import SwiftUI
import CoreGPX
import CoreLocation.CLLocation

class FileExporter: NSObject, ObservableObject {

    static let shared = FileExporter()

    @Published var isSharing = false

    var FilesFolderURL: URL {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl
    }

    /// Export a Log to a chosen file type and share it via iOS ShareSheet
    ///
    /// - Parameters:
    ///     - log: CoreData Entity Log that contains all details about one saved flight.
    ///     - fileType: GPX, CSV, or RAW.
    ///
    func share(log: Log, fileType: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        var fileExt = ""

        DispatchQueue.main.async {
            self.isSharing = true
        }

        let dateFormatterShort: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()

        var fileContents = ""
        if fileType == "gpx" {
            fileContents = writeXML(log: log)
            fileExt = "gpx"
        } else if fileType == "flysight" {
            fileContents = writeCSV(log: log)
            fileExt = "csv"
        } else {
            fileContents = writeRaw(log: log)
            fileExt = "csv"
        }

        let filename = dateFormatterShort.string(from: log.date) + "_\(log.takeOff)"

        save(filename, fileContents: fileContents, fileExt: fileExt) { savedURL in
            DispatchQueue.main.async {
                if let presentingViewController = rootViewController.presentedViewController {
                    presentingViewController.dismiss(animated: true, completion: nil)
                }

                let hostingController = UIHostingController(rootView: ShareLinkView(fileURL: savedURL!))
                hostingController.modalPresentationStyle = .fullScreen
                rootViewController.present(hostingController, animated: true, completion: nil)
                self.isSharing = false
            }
        }
    }


    
    func save(_ filename: String, fileContents: String, fileExt: String, completion: @escaping (URL?) -> Void) {
        let fileURL = self.URLForFilename(filename, fileExt: fileExt) // Use 'self' here
        
        DispatchQueue.main.async {
            do {
                try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Saved file to: \(fileURL)")
                print("File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
                completion(fileURL)
            } catch {
                print("Error saving file to URL: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    
    func URLForFilename(_ filename: String, fileExt: String) -> URL {
        var fullURL = FilesFolderURL.appendingPathComponent(filename)
        fullURL = fullURL.appendingPathExtension(fileExt)
        return fullURL
    }
    
    /// Write a CSV string
    ///
    /// - Parameters:
    ///     - log: CoreData Entitiy Log that contains all details about one saved flight.
    /// - Returns:
    ///     A `String` that can be saved to a file.
    ///
    func writeCSV(log: Log) -> String {
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
            let velN = cos(log.course[i]) * log.speedHorizontal[i]
            let velE = sin(log.course[i]) * log.speedHorizontal[i]
            
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
    
    /// Write a CSV string
    ///
    /// - Parameters:
    ///     - log: CoreData Entitiy Log that contains all details about one saved flight.
    /// - Returns:
    ///     A `String` that can be saved to a file.
    ///
    func writeRaw(log: Log) -> String {
        var deviceType = ""
        if log.fromWatch { deviceType = "Apple Watch" } else { deviceType = "Apple iPhone" }
        
        var csv: String = """
Date:,\(log.date)
Pilot:,\(log.pilot)
Wing:,\(log.glider)
Take Off:,\(log.takeOff)
Flight Time:,\(log.flightTime)
Recorded on:,\(deviceType)
ID:,\(log.id)
,
timestamp,longitude,latitude,altitudeGPS,altitudeBarometer,speedVertical,speedHorizontal,course,accuracyHorizontal,accuracyVertical,accuracySpeed
"""
        
        var i = 0
        
        for _ in log.accuracyHorizontal {
            csv.append("\n" + log.timestamps[i] + ",\(log.longitude[i]),\(log.latitude[i]),\(log.altitudeGPS[i]),\(log.altitudeBarometer[i]),\(log.speedVertical[i]),\(log.speedHorizontal[i]),\(log.course[i]),\(log.accuracyHorizontal[i]),\(log.accuracyVertical[i]),\(log.accuracySpeed[i])")
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
    func writeXML(log: Log) -> String {
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
    
    func saveToURL(_ fileURL: URL, fileContents: String) {
        do {
            try fileContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            debugPrint("Saved file to: \(fileURL)")
            debugPrint("File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
        } catch let error as NSError {
            debugPrint("Error saving file to URL: \(error.localizedDescription)")
        }
    }
}
