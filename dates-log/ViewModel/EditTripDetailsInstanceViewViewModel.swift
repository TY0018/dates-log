//
//  EditTripDetailsInstanceViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/1/25.
//

import Foundation

class EditTripDetailsInstanceViewViewModel: ObservableObject {
    @Published var title: String
    @Published var description: String
    @Published var rating: Double
    @Published var date: Date
    @Published var isFavourite: Bool
    @Published var group: String = "No group selected"
    
    var canSave: Bool {
        !title.isEmpty && !description.isEmpty
    }
    
    init(DateInstance instance: DateInstance) {
        self.title = instance.title
        self.description = instance.description
        self.rating = Double(instance.rating)
        self.date = instance.date
        self.isFavourite = instance.isFavourite
    }

    func saveChanges(groupName: String) async {
        // Logic to save changes (e.g., update Firestore)
        print("Changes saved!")
    }

    func setFav(_ newValue: Bool) {
        isFavourite = newValue
    }
}
