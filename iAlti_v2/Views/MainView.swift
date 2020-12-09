//
//  MainView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import MapKit

extension Map {
    func mapStyle(_ mapType: MKMapType) -> some View {
        MKMapView.appearance().mapType = mapType
        return self
    }
}

struct MainView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: LocationManager.shared.lastLocation.coordinate.latitude,
            longitude: LocationManager.shared.lastLocation.coordinate.longitude
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )

    var body: some View {
        VStack {
            VStack {
                if (globals.relativeAltitude + userSettings.offset) > 999 || (globals.relativeAltitude + userSettings.offset) < -999 {
                    Text("\((globals.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [km]")
                        .font(.system(size: 20))
                } else {
                    Text("\(globals.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [m]")
                        .font(.system(size: 20))
                }
            }
            HStack {
                Spacer()
                VStack {
                    Text("\(globals.speedH, specifier: "%.0f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Speed [km/h]")
                        .font(.system(size: 20))
                }
                Spacer()
                VStack {
                    if globals.glideRatio > 99 || globals.glideRatio < 0 {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 100))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else if globals.glideRatio.isNaN || globals.glideRatio == 0 {
                        Text("--")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else {
                        Text("\(globals.glideRatio, specifier: "%.1f")")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    }
                    Text("Glide Ratio")
                        .font(.system(size: 20))
                }
                Spacer()
            }
            Map(
                coordinateRegion: $region,
                interactionModes: MapInteractionModes.zoom,
                showsUserLocation: true,
                userTrackingMode: $userTrackingMode)
                .mapStyle(.satellite)
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
