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
    @Binding var mapView: MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {

    }
}
#Preview {
    MapViewHelper(
        mapView:.constant(LocationManager.shared.mainMapView))
        .environmentObject(LocationManager.shared)
}
