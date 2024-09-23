//
//  UserManager.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var groups: [String] = []
    @Published var userId: String = ""
    
    private init(){
        //initialise user
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        self.userId = userId
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
    
    func createNewGroup(groupName: String) {
        guard self.userId != "" else {
            return
        }
        print("Creating new group")
        let db = Firestore.firestore()
        db.collection("users")
            .document(self.userId)
            .collection("groups")
            .document(groupName)
            .setData([:]) //create empty document
        //add group to local list
        self.groups.append(groupName)
    }
    
    // Fetch trips and pass them to the location manager
    func fetchTrips(for group: String) {
        Task {
            do {
                let trips = try await fetchTrips(group: group)
                DispatchQueue.main.async {
                    LocationManager.shared.updateTrips(trips: trips)
                }
            } catch {
                print("Error fetching trips: \(error)")
            }
        }
    }
    
    private func fetchTrips(group: String) async throws -> [DateEvent] {
        let db = Firestore.firestore()

        do {
            print("userId: ", self.userId)
            print("group: ", group)
            let snapshot = try await db.collection("users")
                .document(self.userId)
                .collection("groups")
                .document(group)
                .collection("trips")
                .getDocuments()
            
            print("docs: ", snapshot.documents)
            
            let trips = snapshot.documents.compactMap { document -> DateEvent? in
                do {
                        return try document.data(as: DateEvent.self)
                    } catch {
                        print("Failed to decode document: \(document.documentID), error: \(error)")
                        return nil
                    }
            }
            print("trips in user manager: ", trips)
            return trips
        } catch {
            print("Error fetching trips: \(error)")
            throw error
        }
    }
    
}
