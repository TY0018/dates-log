//
//  DateInstance.swift
//  dates-log
//
//  Created by Tong Ying on 6/10/24.
//

import Foundation
import FirebaseFirestore

struct DateInstance: Codable {
    let title: String //title of the date
    let description: String //description of the date
    let rating: Double //rating of the date
    let date: Date //datetime of the date
    let isFavourite: Bool //add to favourites or not
    
    
    // Convert your object to a dictionary for saving in Firestore
    func toDict() -> [String: Any] {
        return [
            "title": title,
            "description": description,
            "rating": rating,
            "date": Timestamp(date: date), // Convert Date to Firestore Timestamp
            "isFavourite": isFavourite
        ]
    }
}
