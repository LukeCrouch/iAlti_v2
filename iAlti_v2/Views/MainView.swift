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
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    
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
                if (Altimeter.shared.relativeAltitude + UserSettings.shared.offset) > 999 || (Altimeter.shared.relativeAltitude + UserSettings.shared.offset) < -999 {
                    Text("\((Altimeter.shared.relativeAltitude + UserSettings.shared.offset) / 1000, specifier: "%.2f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [km]")
                        .font(.system(size: 20))
                } else {
                    Text("\(Altimeter.shared.relativeAltitude + UserSettings.shared.offset, specifier: "%.0f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                        .transition(.opacity)
                    Text("Altitude [m]")
                        .font(.system(size: 20))
                }
            }
            HStack {
                Spacer()
                VStack {
                    Text("\(LocationManager.shared.lastLocation.speed, specifier: "%.0f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                        .transition(.opacity)
                    Text("Speed [km/h]")
                        .font(.system(size: 20))
                }
                Spacer()
                VStack {
                    if Altimeter.shared.glideRatio > 99 || Altimeter.shared.glideRatio < 0 {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 100))
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                            .transition(.opacity)
                    } else if Altimeter.shared.glideRatio.isNaN || Altimeter.shared.glideRatio == 0 {
                        Text("--")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
                            .transition(.opacity)
                    } else {
                        Text("\(Altimeter.shared.glideRatio, specifier: "%.1f")")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(UserSettings.shared.colors[UserSettings.shared.colorSelection])
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
