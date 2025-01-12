//
//  AddLogView.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import MapKit

struct CheckConfirmSheetView: View {
    @Binding var confirm: Bool
    @EnvironmentObject var locationManager:LocationManager
    @ObservedObject var viewModel:AddLogMapViewViewModel
    
    var body: some View {
        if let place = locationManager.pickedPlaceMark {
            confirmLocationView(place:place)
        } else {
            Text("Fetching location...")
        }
            
        
    }
    // confirm location sheet
    @ViewBuilder
    func confirmLocationView(place:CLPlacemark) -> some View {
        NavigationStack{
            VStack(spacing:15){
                HStack(spacing: 15){
                    Image(systemName:"mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    VStack(alignment:.leading, spacing: 6){
                        Text(place.name ?? "")
                            .font(.title3.bold())
                        Text(place.thoroughfare ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment:.leading)
                .padding(.vertical, 10)
                Button{
                    //trigger AddLogDetailsView page to slide up
                    viewModel.openAddDetailsPage = true
                    confirm = false
                    viewModel.placeLocation = place.location
                    viewModel.placeName = place.name ?? ""
                } label: {
                    Text("Confirm Location")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color("MainPurple"))
                        }
                        .overlay(alignment: .trailing) {
                            Image(systemName: "arrow.right")
                                .font(.title3.bold())
                                .padding(.trailing)
                        }
                        .foregroundColor(.white)
                }
                        }
            .navigationTitle("Confirm Location")
                .bold()
            .padding()
        }
    }
}


#Preview {
    CheckConfirmSheetView(confirm: .constant(true), viewModel:AddLogMapViewViewModel())
    .environmentObject(LocationManager.shared)
}


