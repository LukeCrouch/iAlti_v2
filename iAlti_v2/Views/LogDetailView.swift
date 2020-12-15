//
//  LogDetailView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 17.11.20.
//

import SwiftUI

struct LogDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var confirmDelete = false
    @State private var sharePresented = false
    
    @ObservedObject var log: Log
    var exportURL: URL?
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.backward")
                    .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                Button(action: { self.presentationMode.wrappedValue.dismiss() },
                       label: { Text("Logs").foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection]) })
                Spacer(minLength: 500)
                Button(
                    action: { sharePresented.toggle() },
                    label: { Image(systemName: "square.and.arrow.up").foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection]) })
                Spacer(minLength: 30)
                Button(
                    action: { confirmDelete.toggle() },
                    label: { Image(systemName: "trash").foregroundColor(.red) })
            }
            .padding([.horizontal, .top])
            TabView {
                LogDetailOverView(log: log)
                    .tabItem {}
                    .tag(0)
                LogDetailGraphView(log: log)
                    .tabItem {}
                    .tag(1)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .actionSheet(isPresented: $confirmDelete) {
            ActionSheet(
                title: Text("Are you sure you want to delete this Log?"),
                buttons: [
                    .destructive(Text("Confirm")) {
                        PersistenceManager.shared.removeLog(log: log)
                        presentationMode.wrappedValue.dismiss()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $sharePresented) {
            ShareSheet(activityItems: [exportURL as Any])
        }
    }
}

struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(log: Log())
    }
}
