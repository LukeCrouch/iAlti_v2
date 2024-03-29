//
//  MainView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 16.11.20.
//

import SwiftUI
import MapKit

struct MainView: View {
    @ObservedObject private var altimeter = Altimeter.shared
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var userSettings = UserSettings.shared
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    private let mainTextSize: CGFloat = 80
    private let secondaryTextSize: CGFloat = 15
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // MARK: Altitude Display
                VStack {
                    if userSettings.unitSelection == 0 { // metric
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
                    } else { //imperial
                        if ((altimeter.relativeAltitude + userSettings.offset) * 3.28084) > 999 || ((altimeter.relativeAltitude + userSettings.offset) * 3.28084) < -999 {
                            Text("\((altimeter.relativeAltitude + userSettings.offset) * 3.28084 / 5280, specifier: "%.2f")")
                                .font(.system(size: mainTextSize))
                                .fontWeight(.bold)
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                                .transition(.opacity)
                            Text("Altitude [miles]")
                                .font(.system(size: secondaryTextSize))
                        } else {
                            Text("\(((altimeter.relativeAltitude + userSettings.offset) * 3.28084) , specifier: "%.0f")")
                                .font(.system(size: mainTextSize))
                                .fontWeight(.bold)
                                .foregroundColor(userSettings.colors[userSettings.colorSelection])
                                .transition(.opacity)
                            Text("Altitude [feet]")
                                .font(.system(size: secondaryTextSize))
                        }
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
                            .rotationEffect(Angle(degrees: locationManager.lastLocation?.course ?? 0))
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
                    if userSettings.unitSelection == 0 { // metric
                        Text("\(((locationManager.lastLocation?.speed ?? 0) * 3.6), specifier: "%.0f")")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Speed [km/h]")
                            .font(.system(size: secondaryTextSize))
                    } else { //imperial
                        Text("\(((locationManager.lastLocation?.speed ?? 0) * 2.23694), specifier: "%.0f")")
                            .font(.system(size: mainTextSize))
                            .fontWeight(.bold)
                            .foregroundColor(userSettings.colors[userSettings.colorSelection])
                            .transition(.opacity)
                        Text("Speed [mph]")
                            .font(.system(size: secondaryTextSize))
                    }
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
            MapViewUIKit(trackingMode: userSettings.mapTrackingMode)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: locationManager.showPrivacyAlert, perform: {_ in
            alertTitle = "Location Usage not allowed!"
            alertMessage = "Please got to Settings -> Privacy and allow this app to use location data (always and precise). Afterwards please restart the app."
            showAlert = locationManager.showPrivacyAlert
        })
    }
}

struct MapViewUIKit: UIViewRepresentable {
    let trackingMode: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: LocationManager.shared.lastLocation?.coordinate.latitude ?? 0,
                longitude: LocationManager.shared.lastLocation?.coordinate.longitude ?? 0
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 1,
                longitudeDelta: 1
            )
        )
        
        let mapView = MKMapView()
        mapView.region = region
        mapView.mapType = MKMapType.hybrid
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsCompass = false
        //mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: CLLocationDistance(5000)) // min zoom radius in metres
        if !trackingMode{
            mapView.userTrackingMode = MKUserTrackingMode.follow
        } else {
            mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        }
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: LocationManager.shared.lastLocation?.coordinate.latitude ?? 0,
                longitude: LocationManager.shared.lastLocation?.coordinate.longitude ?? 0
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 1,
                longitudeDelta: 1
            )
        )
        mapView.setRegion(region, animated: false)
        if !trackingMode{
            mapView.userTrackingMode = MKUserTrackingMode.follow
        } else {
            mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        }
    }
}
