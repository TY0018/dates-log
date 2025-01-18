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
    
    @Published var openCheckConfirmSheet: Bool = false //bool to allow the confirm location sheet to appear
    @Published var openAddDetailsPage: Bool = false //bool to allow the add details page overlay to appear
    @Published var openCreateNewGroupPopUp: Bool = false // bool to set blur background effect when create new group pop up appears
    @Published var finishAdding: Bool = false //bool to go back to MainMapView
    @Published var errorMessage: String? = nil  //error message to show on UI
    //Date details
    @Published var placeName: String = ""
    @Published var placeLocation: CLLocation? = nil
    @Published var title: String = ""
    @Published var date: Date = Date()
    @Published var rating: Double = 0
    @Published var description: String = ""
    @Published var group: String = "No group selected"
    
    private let databaseManager = DatabaseManager.shared
    
    init() {}
    
    //func saves date to corr group
    func saveDate() {
        guard canSave else {
            return
        }
        
        // Convert CLLocation to Firestore GeoPoint
        let geoPoint: GeoPoint = GeoPoint(
            latitude: placeLocation?.coordinate.latitude ?? 0.0,
            longitude: placeLocation?.coordinate.longitude ?? 0.0
        )
        
        // Store common location data in the trip document
        let tripData: [String: Any] = [
            "isFav": false,
            "coordinate": geoPoint, // Storing the location
            "placeName": placeName
        ]
        
        // Store the instance-specific details in the 'instances' collection
        let newInstance = DateInstance(
            title: title,
            description: description,
            rating: rating,
            date: date,
            tripId: placeName,
            group: group
        )
        
        databaseManager.addInstance(groupName: group, tripData: tripData, instanceData: newInstance) { success, message in
            DispatchQueue.main.async {
                        if success {
                            print("Added instance to DB!")
                            self.errorMessage = nil
                            self.openCheckConfirmSheet = false
                            self.openAddDetailsPage = false
                            self.finishAdding = true
                            //reset variables after date is saved
                            self.placeName = ""
                            self.placeLocation = nil
                            self.date = Date()
                            self.rating = 1
                            self.description = ""
                            self.group = "No group selected"

                        } else if let errorMessage = message  {
                            print("error adding duplicate!!!")
                            self.errorMessage = errorMessage
                        }
                    }
                }
    }
    
    var canSave: Bool {
        guard !placeName.trimmingCharacters(in:.whitespaces).isEmpty else {
            return false
        }
        guard !title.trimmingCharacters(in:.whitespaces).isEmpty else {
            return false
        }
        guard !description.trimmingCharacters(in:.whitespaces).isEmpty else {
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
