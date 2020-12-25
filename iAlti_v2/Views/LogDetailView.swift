//
//  LogDetailView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//

import SwiftUI

struct LogDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject private var userSettings = UserSettings.shared
    
    @ObservedObject var log: Log
    
    @State private var showSheet = false
    @State private var sheetTitle = ""
    @State private var sheetButtons: [ActionSheet.Button] = []
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.backward")
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                Button(action: { self.presentationMode.wrappedValue.dismiss() },
                       label: { Text("Logs").foregroundColor(userSettings.colors[userSettings.colorSelection]) })
                Spacer(minLength: 500)
                Button(
                    action: {
                        sheetTitle = "Which file format do you want to export to?"
                        sheetButtons = [
                            .default(Text("GPX")) { FileExporter.share(log: log, fileType: "gpx") },
                            .default(Text("CSV (FlySight Viewer)")) { FileExporter.share(log: log, fileType: "csv") },
                            .cancel()
                        ]
                        showSheet = true
                    },
                    label: { Image(systemName: "square.and.arrow.up").foregroundColor(userSettings.colors[userSettings.colorSelection]) }
                )
                Spacer(minLength: 30)
                Button(
                    action: {
                        sheetTitle = "Are you sure you want to delete this Log?"
                        sheetButtons = [
                            .destructive(Text("Confirm")) {
                                PersistenceManager.shared.deleteLog(log: log)
                                presentationMode.wrappedValue.dismiss()
                            },
                            .cancel()
                        ]
                        showSheet = true
                    },
                    label: { Image(systemName: "trash").foregroundColor(.red) }
                )
            }
            .padding([.horizontal, .top])
            TabView {
                LogDetailOverView(log: log)
                    .tabItem {}
                    .tag(0)
                LogDetailOverView(log: log)
                    .tabItem {}
                    .tag(1)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .actionSheet(isPresented: $showSheet) {
            ActionSheet(
                title: Text(sheetTitle),
                buttons: sheetButtons
            )
        }
    }
}
