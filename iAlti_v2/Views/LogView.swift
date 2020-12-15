//
//  LogView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 13.11.20.
//

import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var selectKeeper = Set<Date>()
    @State private var editMode = EditMode.inactive
    @State private var show_modal: Bool = false
    
    @FetchRequest(entity: Log.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Log.date, ascending: true)]) private var logs: FetchedResults<Log>
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Image(systemName: "trash")
                    .opacity(0)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
            }
        } else {
            return Button(action: {
                deleteLogs()
                editMode = EditMode.inactive
            }) {
                Image(systemName: "trash")
                    .opacity(1)
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
            }
        }
    }
    
    private func removeLog(at offsets: IndexSet) {
        for index in offsets {
            debugPrint("Remove \(index + 1). Log")
            let log = logs[index]
            context.delete(log)
        }
    }
    
    private func deleteLogs() {
        for id in selectKeeper {
            debugPrint("Remove Log", logs.endIndex, "with ID: ", id)
            if let index = logs.lastIndex(where: { $0.date == id })  {
                removeLog(at: IndexSet(integer: index))
            }
        }
        selectKeeper = Set<Date>()
    }
    
    var body: some View {
        List(selection: $selectKeeper){
            ForEach(logs, id: \.date){ log in
                Button(action: { show_modal = true }) {
                    HStack {
                        Text("\(log.date, formatter: formatter)")
                        Text(log.takeOff)
                        Text(log.flightTime.asString(style: .positional))
                    }}
                    .sheet(isPresented: self.$show_modal) {
                        LogDetailView(log: log)
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
                            })
                    }
            }
            .onDelete(perform: removeLog)
        }
        .navigationBarItems(leading: deleteButton,trailing: EditButton())
        .accentColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
        .environment(\.editMode, self.$editMode)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
