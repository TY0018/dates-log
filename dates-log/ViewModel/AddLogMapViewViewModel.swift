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
    
    //Date details
    @Published var placeName: String = ""
    @Published var placeLocation: CLLocation? = nil
    @Published var title: String = ""
    @Published var date: Date = Date()
    @Published var rating: Double = 0
    @Published var description: String = ""
    @Published var group: String = "No group selected"
    @Published var isFavourite: Bool = false
    
    init() {}
    
    func setFav(_ state:Bool){
        self.isFavourite = state
    }
    
    //func saves date to corr group
    func saveDate() {
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
        
        //convert date to string to store as instance document title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        
        let db = Firestore.firestore()
        
        // Step 1: Store common location data in the trip document
        let tripData: [String: Any] = [
            "coordinate": geoPoint, // Storing the location
            "placeName": placeName
        ]
        
        // Step 2: Now store the instance-specific details in the 'instances' collection
        let newInstance = DateInstance(
            title: title,
            description: description,
            rating: rating,
            date: date,
            isFavourite: isFavourite
        )
        
        let userRef = db.collection("users").document(user.uid)
        let groupRef = userRef.collection("groups").document(group)
        let tripRef = groupRef.collection("trips").document(placeName)
        print(userRef, groupRef, tripRef)
        let instanceData = newInstance.toDict()
        
        tripRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Trip document exists, so just add to the "instances" subcollection
                print("Trip document exists. Adding to instances collection.")
                tripRef.collection("instances").document(dateString).setData(instanceData) { err in
                    if let err = err {
                        print("Error writing instance document: \(err)")
                    } else {
                        print("Instance successfully written!")
                    }
                }
                
            } else {
                // Trip document does not exist, create the trip document first, then add the instance
                print("Trip document does not exist. Creating trip document and adding instance.")
                
                // Add trip data
                tripRef.setData(tripData) { err in
                    if let err = err {
                        print("Error writing trip document: \(err)")
                    } else {
                        tripRef.collection("instances").document(dateString).setData(instanceData) { err in
                            if let err = err {
                                print("Error writing instance document: \(err)")
                            } else {
                                print("Instance successfully written!")
                            }
                        }
                    }
                }
            }
        }
        
        //add to favourites as well
        if isFavourite {
            //check if group exists, otherwise create new group
            //            Task {
            //                do {
            //                    let exists = try await checkGroupExists(group: "Favourites")
            //                    if !exists {
            //                        UserManager.shared.createNewGroup(groupName:"Favourites")
            //                    }
            //                } catch {
            //                    print("Error checking group exists: \(error)")
            //                }
            //            }
            let favRef = db.collection("users")
                .document(user.uid)
                .collection("favourites")
                .document(placeName)
            
            let instanceRef = tripRef.collection("instances").document(dateString)
            
            favRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Favourite trip document exists, so just add ref to the "instancesRef" subcollection
                    print("Fav document exists. Adding to instancesRef collection.")
                    favRef.collection("instancesRef").document().setData(["ref":instanceRef]) { err in
                        if let err = err {
                            print("Error writing instance document: \(err)")
                        } else {
                            print("Instance successfully written!")
                        }
                    }
                    
                } else {
                    // Fav document does not exist, create the fav document first, then add the instance ref
                    print("Fav document does not exist. Creating trip document and adding instance.")
                    
                    // Add trip data
                    favRef.setData(tripData) { err in
                        if let err = err {
                            print("Error writing fav document: \(err)")
                        } else {
                            favRef.collection("instancesRef").document().setData(["ref":instanceRef]) { err in
                                if let err = err {
                                    print("Error writing instance document: \(err)")
                                } else {
                                    print("Instance successfully written!")
                                }
                            }
                        }
                    }
                }
                
                //            db.collection("users")
                //                .document(user.uid)
                //                .collection("Favourites")
                //                .document()
                //                .collection("trips")
                //                .document(placeName)
                //                .setData(tripData) { err in
                //                    if let err = err {
                //                        print("Error writing trip document: \(err)")
                //                    } else {
                //                        let instanceData = newInstance.toDict() // Convert DateEvent to dictionary without coordinate/placeName
                //                        db.collection("users")
                //                            .document(user.uid)
                //                            .collection("groups")
                //                            .document("Favourites")
                //                            .collection("trips")
                //                            .document(self.placeName)
                //                            .collection("instances")
                //                            .document(dateString) //use datestring as document id
                //                            .setData(instanceData) { err in
                //                                if let err = err {
                //                                    print("Error writing instance document: \(err)")
                //                                } else {
                //                                    print("Instance successfully written!")
                //                                }
                //                            }
                //                    }
                //                }
                
            }
            
            //reset variables after date is saved
            placeName = ""
            placeLocation = nil
            date = Date()
            rating = 1
            description = ""
            group = "No group selected"
            isFavourite = false
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
