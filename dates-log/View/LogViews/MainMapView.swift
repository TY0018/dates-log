//
//  MainMapView.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct MainMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userManager: UserManager
    @State private var navigationPath = NavigationPath()
    @StateObject var viewModel = MainMapViewViewModel()
    @State private var selectedDetent: PresentationDetent = .medium
     
    var body: some View {
        NavigationStack(path:$navigationPath){
            ZStack{
                MapViewHelper(mapView: $locationManager.mainMapView)
//                    .environmentObject(locationManager)
                    .ignoresSafeArea()

                GroupSelector(viewModel: viewModel)
//                    .environmentObject(locationManager)
//                    .environmentObject(userManager)
                    .position(x: UIScreen.main.bounds.width / 2, y:17)
                    
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
                    print("Main map view on appear")
                    userManager.fetchGroups()
                    locationManager.switchMapMode(to: .viewTrips)
                }
            .onChange(of: viewModel.currentGroup, initial: true) { oldGroup, newGroup in
                print("onchange main map: \(viewModel.currentGroup)")
                    if newGroup != "Select group to view Dates" {
                        print("fetching trips for group")
                        viewModel.fetchTrips(for: newGroup)
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
                    let selectedAnnotations = locationManager.mainMapView.selectedAnnotations
                    if !selectedAnnotations.isEmpty {
                        locationManager.mainMapView.deselectAnnotation(selectedAnnotations[0], animated: true)
                    }
                    locationManager.selectedTrip = nil
                    print("sheet onDisappear")
                    selectedDetent = .medium
                }
            ) {
                if (locationManager.selectedTrip?.0) != nil {
                    PagedTripDetailsInstancesView(viewModel:viewModel, selectedDetent: $selectedDetent)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .presentationDetents([.medium, .large],selection: $selectedDetent)
                        .presentationDragIndicator(.visible)
                        .onAppear(){
                            print("on appear tab view: ", locationManager.selectedTrip?.0 ?? "no trip")
                        }
                }
            }
            .onChange(of: locationManager.selectedTrip?.0, initial:true) { _, _ in
                viewModel.showTripDetails = locationManager.selectedTrip != nil
                print("showTripDetails updated: \(viewModel.showTripDetails)")
            }
            .alert(item:$viewModel.errorMessage){
                errorMessage in
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
//        ZStack {
            Picker("Select a group", selection: $viewModel.currentGroup) {
                //default text
                HStack(spacing:5){
                        Image(systemName: "xmark.circle")
                        Spacer()
                        Text("Select group to view Dates")
                    }
                    .tag("Select group to view Dates" as String)
                    .frame(maxWidth:.infinity)
                //list of existing groups
                ForEach(
                    userManager.groups,
                    id: \.self
                ) { group in
                    HStack {
                        Image(systemName: group == "Favourites" ? "suit.heart.fill" : "person.3.fill") // Example icon
                        Spacer()
                            Text(group)
                        }
                        .tag(group as String)
                        .frame(maxWidth:.infinity)
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
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
    }
}

//Sheet with the trip instances for one location
struct PagedTripDetailsInstancesView: View {
    @ObservedObject var viewModel:MainMapViewViewModel
    @EnvironmentObject var locationManager:LocationManager

    @Binding var selectedDetent:PresentationDetent
    
    var body: some View {
        NavigationStack{
//            ScrollView{
                if let selectedTrip = locationManager.selectedTrip {
                    VStack(alignment:.leading, spacing:16){
                        HStack{
                            Text(selectedTrip.0)
                                .font(.title2.bold())
                                .lineLimit(2) // Ensure title does not overflow
                                .truncationMode(.tail)
                            Spacer()
                            Image(systemName: selectedTrip.1 ? "suit.heart.fill" : "suit.heart")
                                .font(.title)  // Adjust the font size as needed
                                .foregroundColor(selectedTrip.1 ? .pink : .gray)  // Change color based on state
                                .onTapGesture {
                                    // Toggle the heart image state
                                    viewModel.updateFav(isFav: !selectedTrip.1, tripId: selectedTrip.0)
                                }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        TabView {
                            ForEach(selectedTrip.3, id: \.id) { instance in
                                TripDetailsInstanceView( selectedDetent: $selectedDetent, placeName: selectedTrip.0,
                                                         instance: instance)
                                    .padding(.bottom, 30)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle()) // Set the tab view style to page
                    }
                    .padding(12)
                    .frame(maxHeight:.infinity, alignment: .topLeading)
                } else {
                    Text("No trip selected.") // Fallback UI if selectedTrip is nil
                }
//            }
        }
        .onAppear {
            // Customize the page control appearance at the bottom
            let appearance = UIPageControl.appearance()
            appearance.currentPageIndicatorTintColor = UIColor(red: 0.76, green: 0.43, blue: 0.55, alpha: 1.0) // Color of the selected page indicator
            appearance.pageIndicatorTintColor = UIColor.gray // Color of the unselected page indicators
        }
        .frame(maxHeight: .infinity) // Set a height for the TabView
    }
}

#Preview {
    MainMapView()
        .environmentObject(LocationManager.shared)
        .environmentObject(UserManager.shared)
}
