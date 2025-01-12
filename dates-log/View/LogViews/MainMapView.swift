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

                GroupSelector(viewModel: viewModel)
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
            .sheet(isPresented: $viewModel.showTripDetails,
                   onDismiss: {
                        // Deselect the selected annotation when the sheet is dismissed
                        if let selectedTrip = locationManager.selectedTrip?.0 {
                            locationManager.mainMapView.deselectAnnotation(selectedTrip as? MKAnnotation, animated: true)
                            print("sheet onDisappear")
                            locationManager.selectedTrip = nil
                        }
                }
            ) {
                if let selectedTrip = locationManager.selectedTrip {
                    PagedInstancesView(instances: selectedTrip.1)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .onAppear(){
                            print("on appear tab view: ", locationManager.selectedTrip?.1 ?? "no trip")
                        }
//                        .onDisappear(
//                            perform: {
//                                
//                            }
//                        )
                }
            }
            .onChange(of: locationManager.selectedTrip?.0, initial:true) { _, _ in
                viewModel.showTripDetails = locationManager.selectedTrip != nil
            }
        }
    }
}

//Menu button at the top
struct GroupSelector: View {
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
                        Text("Select group to view Dates")
                    }
                    .tag("Select group to view Dates" as String)
                HStack(spacing:5){
                        Image(systemName: "suit.heart.fill")
                        Spacer()
                        Text("Favourites")
                    }
                    .tag("Favourites" as String)
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

struct PagedInstancesView: View {
    var instances: [DateInstance] // Array of DateInstance

    var body: some View {
        NavigationStack{
            TabView {
                ForEach(instances, id: \.date) { instance in // Ensure each instance has a unique id
                    TripDetailsInstanceView(instance: instance)
                }
                .padding()
            }
            .tabViewStyle(PageTabViewStyle()) // Set the tab view style to page
        }
        .padding(.bottom, 10)
        .onAppear {
            // Customize the page control appearance at the bottom
            let appearance = UIPageControl.appearance()
            appearance.currentPageIndicatorTintColor = UIColor(red: 0.76, green: 0.43, blue: 0.55, alpha: 1.0) // Color of the selected page indicator
            appearance.pageIndicatorTintColor = UIColor.gray // Color of the unselected page indicators
        }
        .frame(maxHeight: .infinity) // Set a height for the TabView
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
