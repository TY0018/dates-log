//
//  Date.swift
//  dates-log
//
//  Created by Tong Ying on 9/9/24.
//

import Foundation
import FirebaseFirestore
import MapKit

struct DateEvent: Codable {
    let coordinate: GeoPoint //geopoint data struct from firestore
    let title: String
    let description: String
    let rating: Float
    let date: Date
    let isFavourite: Bool
    
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return annotation
    }
}
