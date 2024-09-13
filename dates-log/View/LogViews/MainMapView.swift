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
    @State private var navigationPath = NavigationPath()
    @StateObject var viewModel = MainMapViewViewModel()
     
    var body: some View {
        NavigationStack(path:$navigationPath){
            ZStack{
                MapViewHelper()
                    .environmentObject(locationManager)
                    .ignoresSafeArea()
                TripSelector(viewModel: viewModel)
                    .position(x: UIScreen.main.bounds.width / 2, y:30)
                    .sheet(isPresented: $viewModel.showTripDetails) {
                        if let selectedTrip = locationManager.selectedTrip {
                            TripView(trip: $locationManager.selectedTrip)
                                .presentationDetents([.medium, .large])
                                        .presentationDragIndicator(.visible)
                        }
                    }
                    .onChange(of: locationManager.selectedTrip?.title, initial:true) { _, _ in
                        viewModel.showTripDetails = locationManager.selectedTrip != nil
                    }
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
                    navigationPath = NavigationPath()  // Reset the path when appearing
                locationManager.mapMode = .viewTrips
                }
            .navigationDestination(for: SearchView.self) { view in
                            view
                        }
        }
    }
}

//Menu button at the top
struct TripSelector: View {
    @StateObject var userManager = UserManager.shared
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
        .onAppear {
            userManager.fetchGroups()
        }
        .onChange(of: viewModel.currentGroup, initial: false) { oldGroup, newGroup in
                if newGroup != "No group selected" {
                    userManager.fetchTrips(for: newGroup)
                }
            }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct TripView: View {
    @Binding var trip: DateEvent?
    
    // Date formatting function
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // You can change the style as needed
        formatter.timeStyle = .short   // Optional, if you want to show time
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing:15){
            VStack(spacing:6){
                Text("Location")
                    .font(.headline)
                Text(trip?.title ?? "")
                Text(formatDate(trip?.date ?? Date()))
            }
            VStack(spacing:6){
                Text("Rating")
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
            VStack(spacing:6){
                Text("Description")
                    .font(.headline)
                Text(trip?.description ?? "")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    MainMapView()
        .environmentObject(LocationManager.shared)
}
