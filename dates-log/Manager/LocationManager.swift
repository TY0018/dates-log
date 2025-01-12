//
//  LocationManager.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//
import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    static let shared = LocationManager()
    enum MapMode {
        case viewTrips, addLog
    }

    @Published var mapMode: MapMode = .viewTrips
    
    @Published var mainMapView: MKMapView = .init()
    @Published var addLogMapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    //AddLogMapView
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    //user location
    @Published var userLocation: CLLocation?
    //final location chosen for adding new date
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    
    //MainMapView
    //selected cur trip locations
    @Published var curTripLocations: [String: (CLLocationCoordinate2D, [DateInstance])] = [:]
    //selected trip to display details
    @Published var selectedTrip: (CLLocationCoordinate2D, [DateInstance])? = nil
    
    override private init() {
        super.init()
        mainMapView.delegate = self
        addLogMapView.delegate = self
        manager.delegate = self
        
        //requesting location access
        manager.requestWhenInUseAuthorization()
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Handle error
        print("Location Manager failed.")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let currentLocation = locations.last else{
            print("no location")
            return
        }
        self.userLocation = currentLocation
    }
    
    //Location authorisation
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways:
            print("authorised always")
            manager.requestLocation()
        case .authorizedWhenInUse: 
            print("authorised when in use")
            manager.requestLocation()
        case .denied: 
            print("denied")
            handleLocationError()
        case .notDetermined: 
            print("not determined")
            manager.requestWhenInUseAuthorization()
        default:
            print("default")
        }
    }
    
    func handleLocationError() {
        print("Location access denied.")
    }
    
    func switchMapMode(to newMode: MapMode) {
        mapMode = newMode
        if newMode == .viewTrips {
            addLogMapView.removeAnnotations(addLogMapView.annotations) // Clear addLogMapView
            updateAnnotations() // Update mainMapView with trip markers
            setRegionToFitTrips()
        } else if newMode == .addLog {
            mainMapView.removeAnnotations(mainMapView.annotations) // Clear mainMapView
            // Prepare addLogMapView for adding a new log
        }
    }
    
    //AddLogMapView
    //fetch places from search
    func fetchPlaces(value: String) {
        //fetch locations using MKLocalSearch & Async/Await
        Task{
            do{
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                await MainActor.run(body:{
                    self.fetchedPlaces = response.mapItems.compactMap({item -> CLPlacemark? in return item.placemark})
                })
            } catch {
                //handle error
                print("Failed to fetch place")
            }
        }
    }
    //addLogMapView: add draggable pins
    func addDraggablePin(coordinate: CLLocationCoordinate2D){
        if mapMode == .addLog {
            addLogMapView.removeAnnotations(addLogMapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Date Location"
            print("annotation", annotation)
            addLogMapView.addAnnotation(annotation)
        }
    }
    
    //addLogMapView: enable dragging
    func mapView(_ mapView: MKMapView, viewFor annotation:MKAnnotation) -> MKAnnotationView? {
        if mapMode == .addLog {
            let marker = MKMarkerAnnotationView(annotation:annotation, reuseIdentifier:"Date Location")
            marker.isDraggable = true
            marker.canShowCallout = false
            
            return marker
        }
        return nil
    }
    
    //update new placemark
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else {
            return
        }
        if mapMode == .addLog{
            self.pickedLocation = .init(latitude:newLocation.latitude, longitude: newLocation.longitude)
            updatePlacemark(location: .init(latitude:newLocation.latitude, longitude:newLocation.longitude))
        }
    }
    
    func updatePlacemark(location:CLLocation){
        Task{
            do{
                guard let place = try await reverseLocationCoordinates(location: location) else {
                    return
                }
                await MainActor.run(body: {self.pickedPlaceMark = place}
                )
            } catch {
                print("Failed to update placemark.")
            }
        }
    }
    
    //displaying new location data
    func reverseLocationCoordinates(location: CLLocation)async throws->CLPlacemark?{
        print("location in reverse: ", location)
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
    
    //MainMapView
    //fetch trips for selected group
    func updateTrips(trips: [String: (CLLocationCoordinate2D, [DateInstance])]){
        self.curTripLocations = trips
        print("update trips")
        updateAnnotations()
        setRegionToFitTrips()
    }
    
    //for MainMapView: showing trip markers
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            print("unselected")
            LocationManager.shared.selectedTrip = nil // Safely set selectedTrip to nil when deselected
            return
        }
    
        if mapMode == .viewTrips, let title = annotation.title ?? "" {
                // Find the trip that matches the annotation title using the curTrips dictionary
                if let tripData = curTripLocations[title] {
                    print("selected")
                    selectedTrip = tripData // Assuming you want to access the tuple (CLLocationCoordinate2D, [DateInstance])
                } else {
                    print("annotation but no match")
                    LocationManager.shared.selectedTrip = nil
                }
            }
    }
    
    // MKMapView Delegate for deselecting annotations
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if mapMode == .viewTrips {
            print("deselected")
            // Reset the selected trip when no marker is selected
            LocationManager.shared.selectedTrip = nil
        }
    }

    func removeTrip(by title: String) {
        //remove specific instance
        // check if instances is empty, if yes, remove trip
        curTripLocations.removeValue(forKey: title)
    }
    
    //for MainMapView: showing trip markers
    func updateAnnotations() {
        if mapMode == .viewTrips {
            mainMapView.removeAnnotations(mainMapView.annotations)
            //ignore 2nd element in the tuple
            for (placeName, (coordinate, _)) in curTripLocations {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate // Use the CLLocationCoordinate2D directly
                annotation.title = placeName // Use the place name as the title
                mainMapView.addAnnotation(annotation)
            }
            print("finish adding new annotations")
        }
    }
    
    // Function to set the map region to fit all trip coordinates
    func setRegionToFitTrips() {
        if mapMode == .viewTrips {
            print("setting region")
            guard !curTripLocations.isEmpty else { return }


            // Extract all coordinates from curTrips
            let coordinates = curTripLocations.map { $0.value.0 } // Get the CLLocationCoordinate2D

            // Find the minimum and maximum latitude and longitude
            let minLat = coordinates.map { $0.latitude }.min()!
            let maxLat = coordinates.map { $0.latitude }.max()!
            let minLon = coordinates.map { $0.longitude }.min()!
            let maxLon = coordinates.map { $0.longitude }.max()!

            // Calculate the center of the region
            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)

            // Calculate the span (the zoom level) based on the difference between min and max coordinates
            let spanLat = maxLat - minLat
            let spanLon = maxLon - minLon
            let span = MKCoordinateSpan(latitudeDelta: spanLat * 1.2, longitudeDelta: spanLon * 1.2) // Add some padding

            // Set the region
            let region = MKCoordinateRegion(center: center, span: span)
            mainMapView.setRegion(region, animated: true)
        }
        
    }


}
