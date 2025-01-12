//
//  TripDetailsView.swift
//  dates-log
//
//  Created by Tong Ying on 21/9/24.
//

import SwiftUI

struct TripDetailsView: View {
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
                Text("Trip title")
                Text(formatDate(Date()))
                    .font(.caption)
            }
            VStack(alignment:.leading, spacing:6){
                Text("Rating")
                    .font(.headline)
                HStack(spacing:2){
                    ForEach(0..<Int(4.5), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }

                    ForEach(Int(4.5 )..<5, id: \.self) { _ in
                            Image(systemName: "star")
                                .foregroundColor(.gray)
                        }
                }
            }
            VStack(alignment:.leading, spacing:6){
                Text("Description")
                    .font(.headline)
                Text("Trip description")
            }
            Spacer()
            Button{
                //Edit trip details
            } label: {
                Text("Edit details")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("MainPurple"))
                    }
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TripDetailsView()
}
