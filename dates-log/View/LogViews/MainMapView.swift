//
//  MainMapView.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import MapKit


struct MainMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userManager: UserManager
    @State private var navigationPath = NavigationPath()
    @StateObject var viewModel = MainMapViewViewModel()
     
    var body: some View {
        NavigationStack(path:$navigationPath){
            ZStack{
                MapViewHelper(mapView: $locationManager.mainMapView)
                    .environmentObject(locationManager)
                    .ignoresSafeArea()

                TripSelector(viewModel: viewModel)
                    .environmentObject(locationManager)
                    .environmentObject(userManager)
                    .position(x: UIScreen.main.bounds.width / 2, y:30)
                    
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button{
                            navigationPath.append(SearchView(navigationPath: $navigationPath))
                        } label:
                        {
                            FloatingButton()
                        }
                    }
                }
            }
            .onAppear {
//                    navigationPath = NavigationPath()
                    print("Main map view on appear")
                    userManager.fetchGroups()
                    locationManager.switchMapMode(to: .viewTrips)
                }
            .onChange(of: viewModel.currentGroup, initial: true) { oldGroup, newGroup in
                print("onchange main map")
                    if newGroup != "No group selected" {
                        print("fetching trips for group")
                        userManager.fetchTrips(for: newGroup)
                    }
                }
            .onDisappear{
                locationManager.switchMapMode(to: .addLog)
            }
            .navigationDestination(for: SearchView.self) { view in
                            view
                        }
            .sheet(isPresented: $viewModel.showTripDetails) {
                if let selectedTrip = locationManager.selectedTrip {
                    TripView(trip: $locationManager.selectedTrip, viewModel:viewModel)
                        .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                }
            }
            .onChange(of: locationManager.selectedTrip?.title, initial:true) { _, _ in
                viewModel.showTripDetails = locationManager.selectedTrip != nil
            }
            .onDisappear(
                perform: {
                    locationManager.selectedTrip = nil
                }
            )
        }
    }
}

//Menu button at the top
struct TripSelector: View {
    @EnvironmentObject var userManager:UserManager
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var viewModel:MainMapViewViewModel
    
    var body: some View {
        ZStack {
            Picker("Select a group", selection: $viewModel.currentGroup) {
                //default text
                HStack(spacing:5){
                        Image(systemName: "xmark.circle")
                        Spacer()
                        Text("No group selected")
                    }
                    .tag("No group selected" as String)
                //list of existing groups
                ForEach(userManager.groups, id: \.self) { group in
                    HStack {
                            Image(systemName: "person.3.fill") // Example icon
                            Text(group)
                        }
                        .tag(group as String)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .frame(maxWidth:.infinity)
            .background {
                RoundedRectangle(cornerRadius:15)
                    .foregroundColor(.white)
                    .shadow(radius:5)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct TripView: View {
    @Binding var trip: DateEvent?
    @State var isEdit: Bool = false
    @ObservedObject var viewModel: MainMapViewViewModel
    
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
                Text(trip?.title ?? "")
                Text(formatDate(trip?.date ?? Date()))
                    .font(.caption)
            }
            VStack(alignment:.leading, spacing:6){
                Text("Rating")
                    .font(.headline)
                HStack(spacing:2){
                    ForEach(0..<Int(trip?.rating ?? 1), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    ForEach(Int(trip?.rating ?? 1)..<5, id: \.self) { _ in
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                    }
                }
            }
            VStack(alignment:.leading, spacing:6){
                Text("Description")
                    .font(.headline)
                Text(trip?.description ?? "nil")
            }
            Spacer()
//            HStack(spacing: 3) {
//                Button{
//                    //Delete trip
//                    if let currentTrip = trip {
//                        viewModel.deleteDate(group:viewModel.currentGroup, trip:currentTrip)
//                        viewModel.showTripDetails = false //close sheet after delete
//                    }
//                    
//                    
//                } label: {
//                    Text("Delete Date")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background {
//                            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                .fill(Color.gray)
//                        }
//                        .foregroundColor(.white)
//                }
//                Button{
//                    //Edit trip details
//                    isEdit = true
//                } label: {
//                    Text("Edit details")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background {
//                            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                .fill(Color("MainPurple"))
//                        }
//                        .foregroundColor(.white)
//                }
//            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment:.leading)
        .padding()
    }
}

#Preview {
    MainMapView()
        .environmentObject(LocationManager.shared)
        .environmentObject(UserManager.shared)
}
