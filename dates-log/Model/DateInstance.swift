//
//  DateInstance.swift
//  dates-log
//
//  Created by Tong Ying on 6/10/24.
//

import Foundation
import FirebaseFirestore

struct DateInstance: Codable {
    @DocumentID var id: String?
    let title: String //title of the date
    let description: String //description of the date
    let rating: Double //rating of the date
    let date: Date //datetime of the date
    let tripId: String // placeName
    let group: String // group it belongs to
    
    //helper function to standardise the time
    func normalizeToMidnight(date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    // Convert your object to a dictionary for saving in Firestore
    func toDict() -> [String: Any] {
        let normalisedDate = normalizeToMidnight(date: date)
        return [
            "title": title,
            "description": description,
            "rating": rating,
            "date": Timestamp(date: normalisedDate), // Convert Date to Firestore Timestamp
            "tripId": tripId,
            "group": group
        ]
    }
}
