//
//  SearchView.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//
import SwiftUI
import MapKit
import Foundation

struct SearchView: View, Hashable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var navigationPath: NavigationPath
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
    
    var body: some View {
//        NavigationStack{
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
                            NavigationLink(destination: AddLogMapView(navigationPath:$navigationPath)
                                .environmentObject(locationManager)) {
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
                                .simultaneousGesture(TapGesture().onEnded {
                                    //add view to path so that we can go back to MainMapView page
                                    navigationPath.append(AddLogMapView(navigationPath: $navigationPath))
                                    if let coordinate = place.location?.coordinate {
                                        locationManager.pickedLocation = .init(latitude:coordinate.latitude, longitude:coordinate.longitude)
                                        locationManager.mapView.setRegion(MKCoordinateRegion(
                                            center: coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000
                                        ), animated: true)
                                        locationManager.mapMode = .addLog
                                        locationManager.addDraggablePin(coordinate: coordinate)
                                        locationManager.updatePlacemark(location: .init(latitude:coordinate.latitude, longitude: coordinate.longitude))
                                    } else {
                                        print("no coordinate")
                                    }
                                })
                        }
                    }
                    .listStyle(.plain)
                } else {
                    //live location button
                    NavigationLink(destination: AddLogMapView(navigationPath:$navigationPath)
                        .environmentObject(locationManager)) {
                            Label {
                                Text("Use current location")
                                    .font(.callout)
                            } icon: {
                                Image(systemName: "location.north.circle.fill")
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            navigationPath.append(AddLogMapView(navigationPath: $navigationPath))
                            if let coordinate = locationManager.userLocation?.coordinate {
                                locationManager.mapView.region = .init(
                                    center: coordinate,
                                    latitudinalMeters: 1000,
                                    longitudinalMeters: 1000
                                )
                                locationManager.mapMode = .addLog
                                locationManager.addDraggablePin(coordinate: coordinate)
                                locationManager.updatePlacemark(location: .init(latitude:coordinate.latitude, longitude: coordinate.longitude))
                            } else {
                                print("no coordinate")
                            }
                        })
                }
            }
            .onAppear{
                print(navigationPath)
            }
                    .padding()
                    .frame(maxHeight:.infinity, alignment:.top)
            }
    }




#Preview {
    SearchView(navigationPath:.constant(NavigationPath()))
        .environmentObject(LocationManager.shared)
}
