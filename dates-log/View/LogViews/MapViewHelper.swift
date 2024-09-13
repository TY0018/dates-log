//
//  MapViewHelper.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import MapKit

//UIKit MapView
struct MapViewHelper: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = locationManager.mapView
        mapView.mapType = .standard  // Make sure to set the map type
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        locationManager.updateAnnotations()
    }
}
#Preview {
    MapViewHelper()
        .environmentObject(LocationManager.shared)
}
