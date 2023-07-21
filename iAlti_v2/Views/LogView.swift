//
//  LogView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 13.11.20.
//

import SwiftUI
import CoreLocation.CLLocation

struct LogView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject private var userSettings = UserSettings.shared
    
    @State private var selectKeeper = Set<UUID>()
    @State private var editMode = EditMode.inactive
    @State private var showModal: Bool = false
    @ObservedObject var logDetailOverViewModel = LogDetailOverViewModel()
    
    @FetchRequest(entity: Log.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Log.date, ascending: true)]) private var logs: FetchedResults<Log>
    
    let dateFormatterShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Image(systemName: "trash")
                    .opacity(0)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
            }
        } else {
            return Button(action: {
                for id in selectKeeper {
                    debugPrint("Delete Log with ID: ", id)
                    if let index = logs.lastIndex(where: { $0.id == id })  {
                        deleteLog(at: IndexSet(integer: index))
                    }
                }
                selectKeeper = Set<UUID>()
                editMode = EditMode.inactive
            }) {
                Image(systemName: "trash")
                    .opacity(1)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
            }
        }
    }
    
    // MARK: Deletion
    private func deleteLog(at offsets: IndexSet) {
        for index in offsets {
            debugPrint("Delete \(index + 1). Log")
            let log = logs[index]
            context.delete(log)
        }
    }
    
    //MARK: View
    var body: some View {
        List(selection: $selectKeeper){
            ForEach(logs, id: \.id){ log in
                Button(action: { showModal = true }) {
                    HStack {
                        Text("\(log.date, formatter: dateFormatterShort)")
                        Text(log.takeOff).fontWeight(.bold)
                        Text(log.flightTime.asDateString(style: .positional))
                        Spacer()
                        if log.fromWatch {
                            Image(systemName: "applewatch")
                        } else {
                            Image(systemName: "iphone")
                        }
                    }}
                    .sheet(isPresented: self.$showModal) {
                        if !logDetailOverViewModel.loaded {
                            ProgressView("Loading...")
                                .onAppear() {
                                    DispatchQueue.main.async {
                                        AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
                                        //UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                                        //UINavigationController.attemptRotationToDeviceOrientation()
                                        logDetailOverViewModel.load(log: log)
                                    }
                                }
                        } else {
                            LogDetailView(log: log, logDetailOverViewModel: logDetailOverViewModel)
                        }
                    }
            }.onDelete(perform: deleteLog)
        }
        .navigationBarItems(leading: deleteButton, trailing: EditButton())
        .environment(\.editMode, self.$editMode)
    }
}
