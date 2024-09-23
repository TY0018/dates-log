//
//  LogInViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MainMapViewViewModel: ObservableObject {
    @Published var currentGroup: String = "No group selected"
    @Published var showTripDetails: Bool = false
    
    private let locationManager = LocationManager.shared
    
    init(){}
    
    func editDate() {
        
    }
    
    func deleteDate(group:String, trip: DateEvent){
        //get current user
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(user.uid)
            .collection("groups")
            .document(group)
            .collection("trips")
            .document(trip.title)
        
        docRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                    return
                } else {
                    print("Document \(trip.title) successfully deleted!")
                    //edit LocationManager.curTripLocations
                    self.locationManager.removeTrip(by: trip.title)
                    self.locationManager.updateAnnotations()
                    self.locationManager.setRegionToFitTrips()
                }
            }
    }
}
