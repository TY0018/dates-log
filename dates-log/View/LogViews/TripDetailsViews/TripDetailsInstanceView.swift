//
//  TripDetailsInstanceView.swift
//  dates-log
//
//  Created by Tong Ying on 6/10/24.
//

import SwiftUI
import MapKit

struct TripDetailsInstanceView: View {
    @Binding var selectedDetent: PresentationDetent
    
    var placeName: String
    var instance: DateInstance // Your model for instances
    
    @State private var errorMessage: String? = nil // For deleting instance
    @State private var isEditing = false // Track whether edit view is shown
    
    // Date formatting function
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment:.leading, spacing:15){
            VStack(alignment:.leading, spacing:6){
                Text("Title")
                    .font(.headline)
                    .foregroundStyle(Color("MainPurple"))
                Text(instance.title)
                Text(formatDate(instance.date))
                    .font(.caption)
            }
            VStack(alignment:.leading, spacing:6){
                Text("Went out with")
                    .font(.headline)
                    .foregroundStyle(Color("MainPurple"))
                Text(instance.group)
            }
            VStack(alignment:.leading, spacing:6){
                Text("Rating")
                    .font(.headline)
                    .foregroundStyle(Color("MainPurple"))
                HStack(spacing:2){
                    ForEach(0..<Int(instance.rating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }

                    ForEach(Int(instance.rating )..<5, id: \.self) { _ in
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                        }
                }
            }
            VStack(alignment:.leading, spacing:6){
                Text("Description")
                    .font(.headline)
                    .foregroundStyle(Color("MainPurple"))
                Text(instance.description)
            }
            Spacer()
            NavigationLink(destination: EditTripDetailsInstanceView(
                selectedDetent:$selectedDetent,
                viewModel: EditTripDetailsInstanceViewViewModel(placeName: placeName, instance: instance)
            )
//                .onAppear{selectedDetent = .large}
                            .navigationTitle("Edit Details")
                            .bold()) {
                            Text("Edit Details")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color("MainPurple"))
                                }
                                .overlay(alignment: .trailing) {
                                    Image(systemName: "pencil")
                                        .font(.title3.bold())
                                        .padding(.trailing)
                                }
                                .foregroundColor(.white)
                            }
            Button {
                DatabaseManager.shared.deleteInstance(instanceId: instance.id!) { success, message in
                    DispatchQueue.main.async {
                                if success {
                                    print("Instance successfully deleted!")
                                    errorMessage = nil
                                    // Refresh instances after adding
                                    DatabaseManager.shared.fetchInstances( groupName: self.instance.group){
                                        success, message in
                                        if !success {
                                                print("Failed to refresh instances.")
                                        } else {
                                            print("Refreshed instances!!")
                                        }
                                    }
                                } else {
                                    print(message!)
                                    errorMessage = message
                                }
                            }
                        }
            } label:{
                Text("Delete Date")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.gray)
                    }
                    .overlay(alignment: .trailing) {
                        Image(systemName: "trash.fill")
                            .font(.title3.bold())
                            .padding(.trailing)
                    }
                    .foregroundColor(.white)
            }
            
        }
        .padding(.horizontal, 20)
        .alert(item: $errorMessage) {
            errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

//#Preview {
//    TripDetailsInstanceView(instance: DateEvent(title: "title", description: "description", rating:3, date:Date(), isFavourite: true))
//}
