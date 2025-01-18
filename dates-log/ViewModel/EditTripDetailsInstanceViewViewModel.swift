//
//  EditTripDetailsInstanceViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import MapKit

class EditTripDetailsInstanceViewViewModel: ObservableObject {
    @Published var placeName: String
    @Published var title: String
    @Published var description: String
    @Published var rating: Double
    @Published var date: Date
//    @Published var isFavourite: Bool
    @Published var group: String
    @Published var hasError:Bool = false
    @Published var errorMessage: String? = nil
    
    private let databaseManager = DatabaseManager.shared
    private let instanceId: String
    
    var canSave: Bool {
        !title.isEmpty && !description.isEmpty
    }
    
    init(placeName: String, instance: DateInstance) {
        self.placeName = placeName
        self.title = instance.title
        self.description = instance.description
        self.group = instance.group
//        self.oldGroup = group
        self.rating = Double(instance.rating)
        self.date = instance.date
        self.instanceId = instance.id!
    }

    func saveChanges() {
        // Logic to save changes (e.g., update Firestore)
        //get current user
        let updatedData = DateInstance(
            title: title,
            description: description,
            rating: rating,
            date: date,
            tripId: placeName,
            group: group
        )
                
        databaseManager.editInstance(instanceId: instanceId, updatedData: updatedData) { [weak self] success, message in
            DispatchQueue.main.async {
                if success {
                    guard let self = self else {return}
                    // Refresh instances after editing
                    print("Edited instance to DB!")
                    self.hasError = false
                    self.errorMessage = nil
                    // Refresh instances after adding
                    self.databaseManager.fetchInstances(groupName: self.group){
                        success, message in
                        if !success {
                                print("Failed to refresh instances.")
                        } else {
                            print("Refreshed instances!!")
                        }
                    }
                } else {
                    self?.hasError = true
                    self?.errorMessage = message
                }
            }
        }
    }
        
}
