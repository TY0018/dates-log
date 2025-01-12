//
//  UserManager.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import MapKit

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var groups: [String] = []
    @Published var userId: String = ""
    @Published var createGroupFail: Bool = false
    @Published var user: User?
    
    private init(){
        //initialise user
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        self.userId = userId
        Task {
            let fetchedUser = await fetchUserDetails()
            await MainActor.run {
                self.user = fetchedUser
            }
        }
    }
    
    func fetchUserDetails() async -> User? {
            do {
                let db = Firestore.firestore()
                let document = try await db.collection("users")
                    .document(self.userId)
                    .getDocument()
                let data = document.data()
                return User(
                    uId: document.documentID,
                    tokenId: data?["id"] as? String ?? "",
                    name: data?["name"] as? String ?? "",
                    email: data?["email"] as? String ?? ""
                )
            } catch {
                print(error)
                return nil
            }
    }
    
    func fetchGroups() {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("Cant fetch groups as user is not logged in.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users")
            .document(uId)
            .collection("groups")
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    self.groups = querySnapshot.documents.map{document in
                        print("fetch groups: ", document.documentID)
                        return document.documentID
                    }
                }
            }
    }
    
    func createNewGroup(groupName: String) async {
        guard self.userId != "" else {
            return
        }
        print("Creating new group")
        let db = Firestore.firestore()
        do {
            try await db.collection("users")
                .document(self.userId)
                .collection("groups")
                .document(groupName)
                .setData([:]) //create empty document
        } catch {
            print("Error creating group")
            return
        }
            
        //add group to local list
        self.groups.append(groupName)
    }
    
    func checkGroupExists(group: String) async throws -> Bool {
        //get current user
        guard self.userId != "" else {
            return true
        }
        guard group != "" else {
            return true
        }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("users")
                .document(self.userId)
                .collection("groups")
                .document(group)
                .getDocument()
            
            if snapshot.exists {
                return true
            }
            return false
        } catch {
            print("Error checking group exists: \(error)")
            throw error
        }
    }
    
    // Fetch trips and pass them to the location manager
    func fetchTrips(for group: String) {
        Task {
            let trips: [String: (CLLocationCoordinate2D, [DateInstance])]
            do {
                if group == "Favourites" {
                    trips = try await fetchFav()
                } else {
                    trips = try await fetchTrips(group: group)
                }
                DispatchQueue.main.async {
                    LocationManager.shared.updateTrips(trips: trips)
                }
            } catch {
                print("Error fetching trips: \(error)")
            }
        }
    }
    
    private func fetchTrips(group: String) async throws -> [String: (CLLocationCoordinate2D, [DateInstance])] {
        let db = Firestore.firestore()

        do {
            // Fetch the trips from trip collection
            let snapshot = try await db.collection("users")
                .document(self.userId)
                .collection("groups")
                .document(group)
                .collection("trips")
                .getDocuments()
            
            //key: location Name, value: (coordinates, [dateInstance])
            var tripsDictionary: [String: (CLLocationCoordinate2D, [DateInstance])] = [:]
            
            // Iterate through each trip document
            for document in snapshot.documents {
                // Extract placeName and coordinate from the trip document
                let placeName = document.documentID
                guard let coordinate = document.get("coordinate") as? GeoPoint else {
                    print("Failed to get coordinates for trip \(placeName)")
                    continue
                }

                // Fetch instances (nested documents under each trip document, instances collection)
                let instancesSnapshot = try await db.collection("users")
                    .document(self.userId)
                    .collection("groups")
                    .document(group)
                    .collection("trips")
                    .document(placeName) // Use placeName as the trip document ID
                    .collection("instances")
                    .getDocuments()
                
                // Decode each instance into DateInstance objects
                let events = instancesSnapshot.documents.compactMap { instanceDoc -> DateInstance? in
                    do {
                        return try instanceDoc.data(as: DateInstance.self)
                    } catch {
                        print("Failed to decode document: \(instanceDoc.documentID), error: \(error)")
                        return nil
                    }
                }
                let sortedEvents = events.sorted(by: { $0.date > $1.date }) // Sort from most recent to earliest
                // Add the placeName and corresponding data to the dictionary
                tripsDictionary[placeName] = (CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), sortedEvents)
            }
            print("trips in user manager: ", tripsDictionary)
            return tripsDictionary
        } catch {
            print("Error fetching trips: \(error)")
            throw error
        }
    }
    
    func fetchFav() async throws -> [String: (CLLocationCoordinate2D, [DateInstance])] {
        let db = Firestore.firestore()
        
        // Fetch favorites collection for the user
        let favouritesRef = db.collection("users").document(self.userId).collection("favourites")
        var tripsDictionary: [String: (CLLocationCoordinate2D, [DateInstance])] = [:]
        
        do {
            let favSnapshot = try await favouritesRef.getDocuments()
            
            for doc in favSnapshot.documents {
                let placeName = doc.documentID
                guard let coordinate = doc.get("coordinate") as? GeoPoint else {
                    print("Failed to get coordinates for trip \(placeName)")
                    continue
                }
                // Fetch instances (nested documents under each trip document, instances collection)
                let instancesSnapshot = try await db.collection("users")
                    .document(self.userId)
                    .collection("favourites")
                    .document(placeName)
                    .collection("instancesRef")
                    .getDocuments()
                var events: [DateInstance] = []
                //loop thru each instance ref
                for doc in instancesSnapshot.documents {
                    if let ref = doc.get("ref") as? DocumentReference {
                        let instanceSnapshot = try await ref.getDocument()
                        
                        if let instanceData = try? instanceSnapshot.data(as: DateInstance.self) {
                            events.append(instanceData)
                        } else {
                            print("Failed to fetch instance details for \(placeName)")
                        }
                    }
                }
                // Add the placeName and corresponding data to the dictionary
                tripsDictionary[placeName] = (CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), events)
            }
            return tripsDictionary
        } catch {
            print("Failed to fetch favorites: \(error.localizedDescription)")
            throw error
        }
    }
}
