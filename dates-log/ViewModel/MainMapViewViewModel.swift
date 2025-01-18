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
    @Published var currentGroup: String = "Select group to view Dates"
    @Published var showTripDetails: Bool = false
    @Published var errorMessage: String? = nil
    
    private let databaseManager = DatabaseManager.shared
    private let locationManager = LocationManager.shared
    
    init(){}
    
    func fetchTrips(for group: String) {
        databaseManager.fetchInstances(groupName: group) { [weak self] success, message in
            DispatchQueue.main.async {
                if success {
                    print("Fetched instances successfully!")
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = message
                }
            }
        }

    }
    
    func updateFav(isFav: Bool, tripId: String){
        databaseManager.updateTripFav(tripId: tripId, isFav: isFav) { [weak self] success, message in
            DispatchQueue.main.async {
                if success {
                    print("Updated trip fav successfully!")
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = message
                }
            }
        }
        locationManager.selectedTrip?.1 = isFav
    }
}
