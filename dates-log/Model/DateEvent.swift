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
    let placeName: String //name of the location
    let title: String //title of the date
    let description: String //description of the date
    let rating: Double //rating of the date
    let date: Date //datetime of the date
    let isFavourite: Bool //add to favourites or not
    let group: String // group it falls under
    
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return annotation
    }
    
    // Convert your object to a dictionary for saving as Event in Firestore
    func toEventDict() -> [String: Any] {
        return [
            "coordinate": coordinate,
            "placeName": placeName,
            "title": title,
            "description": description,
            "rating": rating,
            "date": Timestamp(date: date), // Convert Date to Firestore Timestamp
            "isFavourite": isFavourite
        ]
    }
    // Convert object to a dict when saving as instance in Firestore
    func toInstanceDict() -> [String: Any] {
        return [
            "title": title,
            "description": description,
            "rating": rating,
            "date": Timestamp(date: date), // Convert Date to Firestore Timestamp
            "isFavourite": isFavourite
        ]
    }
}
