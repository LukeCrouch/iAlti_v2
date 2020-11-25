//
//  LogView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 13.11.20.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: Log.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Log.date, ascending: true)]) private var logs: FetchedResults<Log>
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    func removeLog(at offsets: IndexSet) {
        for index in offsets {
            debugPrint("Remove \(index + 1). Log")
            let log = logs[index]
            context.delete(log)
        }
    }
    
    var body: some View {
        List{
            ForEach(logs){ log in
                NavigationLink(destination: LogDetailView(log: log)
                                .onDisappear(perform: {
                                    DispatchQueue.main.async {
                                        AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                                        UINavigationController.attemptRotationToDeviceOrientation()
                                    }
                                })
                                .onAppear(perform: {
                                    AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
                                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                                    UINavigationController.attemptRotationToDeviceOrientation()
                                })) {
                    HStack {
                        Text("\(log.date, formatter: formatter)")
                        Text(log.takeoff)
                        Text(log.flightTime.asString(style: .positional))
                    }
                }
            }.onDelete(perform: removeLog)
        }.navigationBarItems(trailing: EditButton()).accentColor(userSettings.colors[userSettings.colorSelection])
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
