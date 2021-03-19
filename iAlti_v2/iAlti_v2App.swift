//
//  iAlti_v2App.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

class ViewSelection: ObservableObject {
    @Published var view: Int = 2
}

@main
struct iAlti_v2App: App {
    let persistence = PersistenceManager()
    @StateObject var viewSelection = ViewSelection()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.context)
                .environmentObject(viewSelection)
        }
    }
}

class AppDelegate: NSObject {
    static var orientationLock = UIInterfaceOrientationMask.portrait
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
