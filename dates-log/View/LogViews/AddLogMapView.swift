//
//  MapView.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//

import SwiftUI
import MapKit
import Foundation

//MapView Live Selection
struct AddLogMapView: View, Hashable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel = AddLogMapViewViewModel()
    
    // Unique identifier for instances
    let id = UUID()
    
    static func == (lhs: AddLogMapView, rhs: AddLogMapView) -> Bool {
        // Compare instances based on unique identifier
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        // Use the unique identifier to generate the hash value
        hasher.combine(id)
    }
    
    var navBackBtn: some View {
        Button(action: {
            //pop last item out of navigation stack
            print("remove search view from stack")
            navigationPath.removeLast()
        }) {
            HStack {
                Image(systemName: "chevron.backward") // set image here
                    .aspectRatio(contentMode: .fit)
                Text("Back")
            }
            .foregroundColor(Color("MainPurple"))
        }
    }
        
    var body: some View {
            ZStack{
                MapViewHelper(mapView: $locationManager.addLogMapView)
                    .environmentObject(locationManager)
                    .ignoresSafeArea()
            }
            .onChange(of:locationManager.pickedPlaceMark?.name, initial:true){
                oldPlaceMark, newPlaceMark in
                    if newPlaceMark != nil {
                        viewModel.checkConfirm = true
                    }
            }
            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navBackBtn)
            .sheet(isPresented:$viewModel.checkConfirm){
                AddLogView(confirm:$viewModel.checkConfirm, viewModel:viewModel)
                    .presentationDetents([.medium, .large]) // This sets the sheet to either medium or large height
                            .presentationDragIndicator(.visible)
                            .onDisappear {
                                // When the sheet closes, navigate back
                                print(navigationPath)
                                if viewModel.finishAdding {
                                    locationManager.pickedLocation = nil
                                    locationManager.pickedPlaceMark = nil
//                                    locationManager.addLogMapView.removeAnnotations(locationManager.addLogMapView.annotations)
//                                    locationManager.switchMapMode(to: .viewTrips)

                                    navigationPath.removeLast(navigationPath.count)
                                }
                            }
            }
    }
}



#Preview {
    AddLogMapView(navigationPath: .constant(NavigationPath()))
        .environmentObject(LocationManager.shared)
}



