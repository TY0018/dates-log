//
//  SearchView.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//
import SwiftUI
import MapKit
import Foundation
import Combine

struct SearchView: View, Hashable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var navigationPath: NavigationPath
    @State private var cancellable: AnyCancellable?
    // Unique identifier for instances
    let id = UUID()
    
    static func == (lhs: SearchView, rhs: SearchView) -> Bool {
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
            locationManager.switchMapMode(to: .viewTrips)
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
            VStack {
                    HStack(spacing: 15, content: {
                        Text("Search Location")
                    })
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment:.leading)
                    HStack(spacing: 15){
                        Image(systemName:"magnifyingglass")
                        TextField("Enter location name", text: $locationManager.searchText)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background{
                        RoundedRectangle(cornerRadius:10, style: .continuous)
                            .strokeBorder(.gray)
                    }
                    if let places = locationManager.fetchedPlaces, !places.isEmpty{
                        List{
                            ForEach(places, id: \.self){
                                place in
                                Button{
                                    navigationPath.append(
                                        AddLogMapView(navigationPath: $navigationPath)
                                    )
                                    if let coordinate = place.location?.coordinate {
                                        locationManager.pickedLocation = .init(latitude:coordinate.latitude, longitude:coordinate.longitude)
                                        locationManager.addLogMapView.setRegion(MKCoordinateRegion(
                                            center: coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000
                                        ), animated: true)
                                        locationManager.addDraggablePin(coordinate: coordinate)
                                        locationManager.updatePlacemark(location: .init(latitude:coordinate.latitude, longitude: coordinate.longitude))
                                    } else {
                                        print("no coordinate")
                                    }
                                } label: {
                                    HStack(spacing:15){
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        VStack(alignment: .leading, spacing: 6, content: {
                                            Text(place.name ?? "")
                                                .font(.title3.bold())
                                            Text(place.locality ?? "")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        })
                                    }
                                }

                            }
                        }
                        .listStyle(.plain)
                    } else {
                        //live location button
                        Button {
                            navigationPath.append(
                                AddLogMapView(navigationPath: $navigationPath)
                            )
                            if let coordinate = locationManager.userLocation?.coordinate {
                                locationManager.addLogMapView.region = .init(
                                    center: coordinate,
                                    latitudinalMeters: 1000,
                                    longitudinalMeters: 1000
                                )
                                locationManager.addDraggablePin(coordinate: coordinate)
                                locationManager.updatePlacemark(location: .init(latitude:coordinate.latitude, longitude: coordinate.longitude))
                            } else {
                                print("no coordinate")
                            }
                        } label: {
                            Label {
                                Text("Use current location")
                                    .font(.callout)
                            } icon: {
                                Image(systemName: "location.north.circle.fill")
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                        }
                        }
            }
            .navigationDestination(for: AddLogMapView.self) { view in
                            view
                        }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navBackBtn)
            .onAppear {
                locationManager.searchText = ""  // Clear search text
                locationManager.fetchedPlaces = nil  // Clear previous search results
                locationManager.mapMode = .addLog
                //initialise searchbar
                cancellable = locationManager.$searchText
                        .debounce(for:.seconds(0.5), scheduler: DispatchQueue.main)
                        .removeDuplicates()
                        .sink(receiveValue: {value in
                            if value != "" {
                                locationManager.fetchPlaces(value:value)
                            } else {
                                locationManager.fetchedPlaces = nil
                            }
                        })
                print(navigationPath)
            }
            .onDisappear{
                //deinitialise search bar
                cancellable?.cancel()
                UIApplication.shared.endEditing(true)
            }
            .padding()
            .frame(maxHeight:.infinity, alignment:.top)
                
            }
    }




#Preview {
    SearchView(navigationPath:.constant(NavigationPath()))
        .environmentObject(LocationManager.shared)
}
