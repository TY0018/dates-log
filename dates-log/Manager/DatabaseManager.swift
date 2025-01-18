//
//  DatabaseManager.swift
//  dates-log
//
//  Created by Tong Ying on 14/1/25.
//

import Foundation
import FirebaseFirestore
import MapKit

class DatabaseManager {
    static let shared = DatabaseManager() // Singleton instance
    
    private let db = Firestore.firestore()
    
    private init() {} // Private initializer to enforce singleton
    private let userId = UserManager.shared.userId

    // Check if instance alr exists
    private func checkForExistingInstance(userRef: DocumentReference, instanceData: DateInstance, completion: @escaping (Bool, String?) -> Void) {
        // Convert instance data to dictionary
        let newInstance = instanceData.toDict()
        
        // Check if instance already exists
        userRef.collection("instances")
            .whereField("tripId", isEqualTo: newInstance["tripId"]!)
            .whereField("date", isEqualTo: newInstance["date"]!)
            .whereField("group", isEqualTo: newInstance["group"]!)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error checking for existing date: \(error)")
                    completion(false, "Error saving Date. Please try again.")
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // A document with the same date already exists
                    print("Instance already exists.")
                    completion(false, "You already logged a Date here on this date. Please choose a different date.")
                    return
                } else {
                    // Proceed to add the new instance since no duplicates were found
                    completion(true, nil)
                }
            }
    }
    
    private func addNewInstance(userRef: DocumentReference, instanceData: DateInstance, completion: @escaping (Bool, String?) -> Void){
        
        let newInstance = instanceData.toDict()
        
        let instanceRef = userRef.collection("instances").document()
        instanceRef.setData(newInstance) { error in
            if error != nil {
                completion(false, "Error while saving instance. Please try again.")
                return
            } else {
                //add tripId to group if it doesn't exist yet
                userRef.collection("groups").document(instanceData.group)
                    .updateData(
                        ["tripIds": FieldValue.arrayUnion([instanceData.tripId])]
                    ) {
                        error in if error != nil {
                            completion(false, "Failed to add trip to group.")
                        }
                    }
                completion(true, instanceRef.documentID)
            }
        }
    }
    
    // Add a new instance
    func addInstance(groupName: String, tripData: [String:Any], instanceData: DateInstance, completion: @escaping (Bool, String?) -> Void) {

        let userRef = db.collection("users").document(userId)
        // Check if trip document exists - create otherwise
        let tripRef = userRef.collection("trips").document(tripData["placeName"] as! String)
        
        tripRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching trip document: \(error)")
                completion(false, "Error saving Date. Please try again.")
                return
            }
            
            //Create trip document if it doesn't exist
            if let document = document, !document.exists {
                print("Trip document does not exist. Creating trip document and adding instance.")
                
                // Add trip data
                tripRef.setData(tripData) { err in
                    if let err = err {
                        print("Error writing trip document: \(err)")
                        completion(false, "Error saving Date. Please try again.")
                        return
                    } else {
                        //Successfully added trip, add instance
                        self.addNewInstance(userRef: userRef, instanceData:instanceData, completion:completion)
                    }
                }
            } else {
                // Check if instance already exists
                // After trip data is written, check for existing instance
                self.checkForExistingInstance(userRef: userRef, instanceData: instanceData) {
                    success, message in
                    if success {
                        self.addNewInstance(userRef: userRef, instanceData:instanceData, completion:completion)
                    } else {
                        completion(false, message)
                        return
                    }
                }
            }
        }
    }
    
    // Edit an instance
    func editInstance(instanceId: String, updatedData: DateInstance, completion: @escaping (Bool, String?) -> Void) {
        let userRef = db.collection("users").document(userId)
        let newData = updatedData.toDict()
        
        // Check if instance (date) is valid
        userRef.collection("instances")
            .whereField("tripId", isEqualTo: newData["tripId"]!)
            .whereField("date", isEqualTo:newData["date"]!)
            .whereField("group", isEqualTo: newData["group"]!)
            .whereField(FieldPath.documentID(), isNotEqualTo: instanceId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error checking for existing date: \(error)")
                    completion(false, "Error saving Date. Please try again.")
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // A document with the same date already exists
                    completion(false, "You already logged a Date here on this date. Please choose a different date.")
                    return
                } else {
                    //Update Data
                    let instanceRef = userRef.collection("instances").document(instanceId)
                    instanceRef.updateData(newData) { error in
                        if error != nil {
                            completion(false, "Error updating instance. Please try again.")
                            return
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
    }
    
    // Delete an instance
    func deleteInstance(instanceId: String, completion: @escaping (Bool, String?) -> Void) {
        let instanceRef = db.collection("users").document(userId)   .collection("instances").document(instanceId)
        instanceRef.delete { error in
            if error != nil {
                completion(false, "Error deleting instance. PLease try again.")
            } else {
                completion(true, nil)
            }
        }
    }
    
    // Query instances
    func fetchInstances(groupName: String, completion: @escaping (Bool, String?) -> Void) {
        let userRef = db.collection("users").document(userId)
        let groupRef = userRef.collection("groups").document(groupName)

        var trips: [String: (Bool, CLLocationCoordinate2D, [DateInstance])] = [:]
        var instances: [DateInstance] = []

        groupRef.getDocument { snapshot, error in
            if error != nil {
                completion(false, "Unable to fetch group. Please try again.")
                return
            }

            guard let tripIds = snapshot?.data()?["tripIds"] as? [String] else {
                // No trips added yet
                completion(true, nil)
                return
            }

            let dispatchGroup = DispatchGroup()

            for tripId in tripIds {
                dispatchGroup.enter()

                // Fetch trip document
                userRef.collection("trips").document(tripId).getDocument { tripSnapshot, error in
                    if let error = error {
                        print("Error fetching trip document: \(error)")
                        dispatchGroup.leave()
                        return
                    }

                    guard let tripData = tripSnapshot?.data(),
                          let coord = tripData["coordinate"] as? GeoPoint,
                          let isFav = tripData["isFav"] as? Bool
                    else {
                        print("Failed to get coordinates for trip \(tripId)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    if groupName == "Favourites" {
                        // Fetch instances related to the tripId
                        userRef.collection("instances")
                            .whereField("tripId", isEqualTo: tripId)
                            .getDocuments { instanceSnapshot, error in
                                if let error = error {
                                    print("Failed to fetch trip instances: \(error)")
                                    dispatchGroup.leave()
                                    return
                                }

                                // Check if there are any instances
                                if let documents = instanceSnapshot?.documents, !documents.isEmpty {
                                    for document in documents {
                                        do {
                                            let instance = try document.data(as: DateInstance.self)
                                            instances.append(instance)
                                        } catch {
                                            print("Error decoding document into DateInstance: \(error)")
                                        }
                                    }
                                    let sortedEvents = instances.sorted(by: { $0.date > $1.date })
                                    trips[tripId] = (isFav, CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude), sortedEvents)
                                    // Reset instances for the next trip
                                    instances = []
                                } else {
                                    // No instances, remove tripId from group
                                    groupRef.updateData([
                                        "tripIds": FieldValue.arrayRemove([tripId])
                                    ]) { error in
                                        if let error = error {
                                            print("Error removing tripId from group: \(error)")
                                        } else {
                                            print("Removed tripId \(tripId) from group \(groupName)")
                                        }
                                    }
                                }
                                dispatchGroup.leave()
                            }
                    } else {
                        // Fetch instances related to the tripId
                        userRef.collection("instances")
                            .whereField("group", isEqualTo: groupName)
                            .whereField("tripId", isEqualTo: tripId)
                            .getDocuments { instanceSnapshot, error in
                                if let error = error {
                                    print("Failed to fetch trip instances: \(error)")
                                    dispatchGroup.leave()
                                    return
                                }

                                // Check if there are any instances
                                if let documents = instanceSnapshot?.documents, !documents.isEmpty {
                                    for document in documents {
                                        do {
                                            let instance = try document.data(as: DateInstance.self)
                                            instances.append(instance)
                                        } catch {
                                            print("Error decoding document into DateInstance: \(error)")
                                        }
                                    }
                                    let sortedEvents = instances.sorted(by: { $0.date > $1.date })
                                    trips[tripId] = (isFav, CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude), sortedEvents)
                                    // Reset instances for the next trip
                                    instances = []
                                } else {
                                    // No instances, remove tripId from group
                                    groupRef.updateData([
                                        "tripIds": FieldValue.arrayRemove([tripId])
                                    ]) { error in
                                        if let error = error {
                                            print("Error removing tripId from group: \(error)")
                                        } else {
                                            print("Removed tripId \(tripId) from group \(groupName)")
                                        }
                                    }
                                }
                                dispatchGroup.leave()
                            }
                    }
//                    // Fetch instances related to the tripId
//                    userRef.collection("instances")
//                        .whereField("group", isEqualTo: groupName)
//                        .whereField("tripId", isEqualTo: tripId)
//                        .getDocuments { instanceSnapshot, error in
//                            if let error = error {
//                                print("Failed to fetch trip instances: \(error)")
//                                dispatchGroup.leave()
//                                return
//                            }
//
//                            // Check if there are any instances
//                            if let documents = instanceSnapshot?.documents, !documents.isEmpty {
//                                for document in documents {
//                                    do {
//                                        let instance = try document.data(as: DateInstance.self)
//                                        instances.append(instance)
//                                    } catch {
//                                        print("Error decoding document into DateInstance: \(error)")
//                                    }
//                                }
//                                let sortedEvents = instances.sorted(by: { $0.date > $1.date })
//                                trips[tripId] = (isFav, CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude), sortedEvents)
//                                // Reset instances for the next trip
//                                instances = []
//                            } else {
//                                // No instances, remove tripId from group
//                                groupRef.updateData([
//                                    "tripIds": FieldValue.arrayRemove([tripId])
//                                ]) { error in
//                                    if let error = error {
//                                        print("Error removing tripId from group: \(error)")
//                                    } else {
//                                        print("Removed tripId \(tripId) from group \(groupName)")
//                                    }
//                                }
//                            }
//                            dispatchGroup.leave()
//                        }
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Update LocationManager with fetched trips
                LocationManager.shared.updateTrips(updatedTrips: trips)
                completion(true, nil)
            }
        }
    }
    
    func updateTripFav(tripId: String, isFav: Bool, completion: @escaping (Bool, String?) -> Void){
        let userRef = db.collection("users").document(userId)
        let tripRef = userRef.collection("trips").document(tripId)
        tripRef.updateData(["isFav":isFav]) { error in
            if error != nil {
                completion(false, "Error favouriting location. Please try again.")
                return
            } else {
                if isFav {
                    // add tripId to favourites group
                    userRef.collection("groups").document("Favourites").updateData(["tripIds":FieldValue.arrayUnion([tripId])]){ error in
                        if let error = error {
                            print("Error adding tripId to favourites: \(error)")
                        } else {
                            print("Added trip to Fav")
                        }
                    }
                    completion(true, nil)
                }
            }
        }
    }

}
