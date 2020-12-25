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
    @ObservedObject private var userSettings = UserSettings.shared
    
    @State private var speedKMH:Double = (LocationManager.shared.lastLocation?.speed ?? 0) * 3.6
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: LocationManager.shared.lastLocation?.coordinate.latitude ?? 0,
            longitude: LocationManager.shared.lastLocation?.coordinate.longitude ?? 0
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 1,
            longitudeDelta: 1
        )
    )
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // MARK: Altitude Display
                VStack {
                    if (altimeter.relativeAltitude + userSettings.offset) > 999 || (altimeter.relativeAltitude + userSettings.offset) < -999 {
                        Text("\((altimeter.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Altitude [km]")
                            .font(.system(size: 15))
                    } else {
                        Text("\(altimeter.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Altitude [m]")
                            .font(.system(size: 15))
                    }
                }
                Spacer(minLength: 50)
                // MARK: Compass Display
                VStack {
                    Text("N")
                    HStack {
                        Text("W")
                        VStack {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 50))
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                                .rotationEffect(Angle(degrees: LocationManager.shared.lastLocation?.course ?? 0))
                        }.frame(width: 80, height: 80, alignment: .center)
                        Text("E")
                    }
                    Text("S")
                }.padding(.top)
                Spacer()
            }
            HStack {
                Spacer()
                // MARK: Speed Display
                VStack {
                    Text("\(speedKMH, specifier: "%.0f")")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Speed [km/h]")
                        .font(.system(size: 15))
                }
                Spacer()
                // MARK: Glide Ratio Display
                VStack {
                    if altimeter.glideRatio > 99 || altimeter.glideRatio < 0 {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 100))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else if altimeter.glideRatio.isNaN || altimeter.glideRatio == 0 {
                        Text("--")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else {
                        Text("\(altimeter.glideRatio, specifier: "%.1f")")
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    }
                    Text("Glide Ratio")
                        .font(.system(size: 15))
                }
                Spacer()
            }
            // MARK: Map Display
            Map( coordinateRegion: $region,
                 interactionModes: MapInteractionModes.zoom,
                 showsUserLocation: true,
                 userTrackingMode: $userTrackingMode)
                .mapStyle(.satellite)
        }
    }
}
