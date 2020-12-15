//
//  ControlsView.swift
//  iAlti v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 11.11.20.
//

import SwiftUI

struct ControlsView: View {
    @Binding var view: Int
    @State private var showModal = false
    @State private var startTime = Date()
    
    private let connectivityProvider = PhoneConnectivityProvider()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: {
                        debugPrint("Start Button pressed")
                        startTime = Date()
                        Altimeter.shared.start()
                        LocationManager.shared.start()
                        view = (view + 1) % 1
                    }, label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    })
                    Text("Start")
                }
                VStack {
                    Button(action: { connectivityProvider.send(duration: DateInterval(start: startTime, end: Date()).duration) },
                           label: {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    })
                    Text("Stop")
                }
            }
            HStack {
                VStack {
                    Button(action: {
                        debugPrint("Reset Button pressed")
                        Altimeter.shared.stopRelativeAltitudeUpdates()
                        Altimeter.shared.start()
                        UserSettings.shared.offset = 0
                        view = (view + 1) % 1
                    }, label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    })
                    Text("Reset")
                }
                VStack {
                    Button(action: {
                        debugPrint("Settings Button pressed")
                        showModal.toggle()
                    }, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                    })
                    Text("Settings")
                }.sheet(isPresented: $showModal) {
                    SettingsView()
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.showModal = false }
                            }
                        })
                }
            }
        }
        .navigationBarTitle("iAlti v2")
        .onAppear(perform: connectivityProvider.connect)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(view: .constant(0))
    }
}
