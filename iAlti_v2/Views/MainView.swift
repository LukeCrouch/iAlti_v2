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
    
    private let mainTextSize: CGFloat = 80
    private let secondaryTextSize: CGFloat = 15
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // MARK: Altitude Display
                VStack {
                    if (altimeter.relativeAltitude + userSettings.offset) > 999 || (altimeter.relativeAltitude + userSettings.offset) < -999 {
                        Text("\((altimeter.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Altitude [km]")
                            .font(.system(size: secondaryTextSize))
                    } else {
                        Text("\(altimeter.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Altitude [m]")
                            .font(.system(size: secondaryTextSize))
                    }
                }
                Spacer(minLength: 50)
                // MARK: Compass Display
                VStack {
                    Text("N").font(.system(size: secondaryTextSize))
                    HStack {
                        Text("W").font(.system(size: secondaryTextSize))
                        Image(systemName: "arrow.up")
                            .font(.system(size: mainTextSize / 1.5 ))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .rotationEffect(Angle(degrees: LocationManager.shared.lastLocation?.course ?? 0))
                            .frame(width: mainTextSize, height: mainTextSize, alignment: .center)
                        Text("E").font(.system(size: secondaryTextSize))
                    }
                    Text("S").font(.system(size: secondaryTextSize))
                }.padding(.top)
                Spacer()
            }
            HStack {
                Spacer()
                // MARK: Speed Display
                VStack {
                    Text("\(speedKMH, specifier: "%.0f")")
                        .font(.system(size: mainTextSize))
                        .fontWeight(.bold)
                        .foregroundColor(userSettings.colors[userSettings.colorSelection])
                        .transition(.opacity)
                    Text("Speed [km/h]")
                        .font(.system(size: secondaryTextSize))
                }
                Spacer()
                // MARK: Glide Ratio Display
                VStack {
                    if altimeter.glideRatio > 99 || altimeter.glideRatio < 0 {
                        Image(systemName: "face.smiling")
                            .font(.system(size: mainTextSize))
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else if altimeter.glideRatio.isNaN || altimeter.glideRatio == 0 {
                        Text("--")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    } else {
                        Text("\(altimeter.glideRatio, specifier: "%.1f")")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                    }
                    Text("Glide Ratio")
                        .font(.system(size: secondaryTextSize))
                }
                Spacer()
            }
            // MARK: Map Display
            MapViewUIKit(region: region, mapType: MKMapType.satellite)
        }
    }
}

struct MapViewUIKit: UIViewRepresentable {
    let region: MKCoordinateRegion
    let mapType : MKMapType
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.mapType = mapType
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.isScrollEnabled = false
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.mapType = mapType
    }
}
