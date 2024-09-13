//
//  MapViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import Foundation
import MapKit
import FirebaseAuth
import FirebaseFirestore

class AddLogMapViewViewModel: ObservableObject {

    @Published var checkConfirm: Bool = false //bool to allow the confirm location sheet to appear
    @Published var finishAdding: Bool = false //bool to go back to MainMapView
    //Date details
    @Published var placeName: String = ""
    @Published var placeLocation: CLLocation? = nil
    @Published var date: Date = Date()
    @Published var rating: Float = 1
    @Published var description: String = ""
    @Published var group: String = "No group selected"
    @Published var isFavourite: Bool = false
    
    init() {}
    
    func setFav(_ state:Bool){
        self.isFavourite = state
    }
    
    //func saves date to corr group
    func saveDate(){
        guard canSave else {
            return
        }
        
        //get current user
        guard let user = Auth.auth().currentUser else {
            return
        }
        // Convert CLLocation to Firestore GeoPoint
        let geoPoint: GeoPoint = GeoPoint(
            latitude: placeLocation?.coordinate.latitude ?? 0.0,
            longitude: placeLocation?.coordinate.longitude ?? 0.0
        )
        let newDate = DateEvent(
            coordinate: geoPoint,
            title: placeName,
            description: description,
            rating: rating,
            date: date,
            isFavourite: isFavourite
        )
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(user.uid)
            .collection("groups")
            .document(group)
            .collection("trips")
            .document(placeName)
            .setData(newDate.asDictionary())
        
        //add to favourites as well
        if isFavourite {
            db.collection("users")
                .document(user.uid)
                .collection("groups")
                .document("Favourites")
                .collection("trips")
                .document(placeName)
                .setData(newDate.asDictionary())
        }
    }
    
    var canSave: Bool {
        guard !placeName.trimmingCharacters(in:.whitespaces).isEmpty else {
            return false
        }
        guard placeLocation != nil else {
            return false
        }
        guard rating > 0 else {
            return false
        }
        guard group != "No group selected" else {
            return false
        }
        return true
    }
    
}
