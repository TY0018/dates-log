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
                
                // AddDetailsView Overlay (new page that slides up)
                if viewModel.openAddDetailsPage {
                    AddDetailsView(viewModel: viewModel, place: locationManager.pickedPlaceMark)
                        .transition(.move(edge: .bottom))
                        .ignoresSafeArea()
                        .zIndex(99)
                }
            }
            .onChange(of:locationManager.pickedPlaceMark?.name, initial:true){
                oldPlaceMark, newPlaceMark in
                    if newPlaceMark != nil {
                        viewModel.openCheckConfirmSheet = true
                    }
            }
            .onChange(of:viewModel.finishAdding){
                print(navigationPath)
                if viewModel.finishAdding {
                    locationManager.pickedLocation = nil
                    locationManager.pickedPlaceMark = nil
                    navigationPath.removeLast(navigationPath.count)
                }
            }
            .animation(.easeInOut, value: viewModel.openAddDetailsPage)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navBackBtn)
            .sheet(isPresented:$viewModel.openCheckConfirmSheet){
                CheckConfirmSheetView(confirm:$viewModel.openCheckConfirmSheet, viewModel:viewModel)
                    .presentationDetents([.medium])
            }
    }
}



#Preview {
    AddLogMapView(navigationPath: .constant(NavigationPath()))
        .environmentObject(LocationManager.shared)
}



