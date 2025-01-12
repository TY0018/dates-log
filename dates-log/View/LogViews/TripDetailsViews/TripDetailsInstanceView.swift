//
//  TripDetailsInstanceView.swift
//  dates-log
//
//  Created by Tong Ying on 6/10/24.
//

import SwiftUI

struct TripDetailsInstanceView: View {
    var instance: DateInstance // Your model for instances
    @State private var isEditing = false // Track whether edit view is shown
    
    // Date formatting function
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // You can change the style as needed
        formatter.timeStyle = .short   // Optional, if you want to show time
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment:.leading, spacing:15){
            Text("Date details")
                .font(.title)
                .bold()
            VStack(alignment:.leading, spacing:6){
                Text("Location")
                    .font(.headline)
                Text(instance.title)
                Text(formatDate(instance.date))
                    .font(.caption)
            }
            VStack(alignment:.leading, spacing:6){
                Text("Rating")
                    .font(.headline)
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
                Text(instance.description)
            }
            Spacer()
//            Button{
//                isEditing = true // Show the edit page
//            } label: {
//                Text("Edit details")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                            .fill(Color("MainPurple"))
//                    }
//                    .foregroundColor(.white)
//            }
            NavigationLink(destination: EditTripDetailsInstanceView(
                viewModel: EditTripDetailsInstanceViewViewModel(DateInstance: instance)
            )
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
        }
        .padding()
//        .sheet(isPresented: $isEditing, onDismiss: {isEditing = false}) {
//                    EditTripDetailsInstanceView(
//                        viewModel: EditTripDetailsInstanceViewViewModel(DateInstance: instance)
//                    )
//                }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

#Preview {
    TripDetailsInstanceView(instance: DateInstance(title: "title", description: "description", rating:3, date:Date(), isFavourite: true))
}
