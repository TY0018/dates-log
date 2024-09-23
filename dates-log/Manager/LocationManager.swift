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
    @Published var curTripLocations: [DateEvent] = []
    //selected trip to display details
    @Published var selectedTrip: DateEvent?
    
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
    func updateTrips(trips: [DateEvent]){
        self.curTripLocations = trips
        print("upadte trips")
        updateAnnotations()
        setRegionToFitTrips()
    }
    
    //for MainMapView: showing trip markers
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if mapMode == .viewTrips, let title = view.annotation?.title {
            // Find the trip that matches the annotation title
            if let trip = curTripLocations.first(where: { $0.title == title }) {
                        selectedTrip = trip
                    }
        }
    }

    func removeTrip(by title: String) {
        if let index = curTripLocations.firstIndex(where: { $0.title == title }) {
            curTripLocations.remove(at: index)
        }
    }
    
    //for MainMapView: showing trip markers
    func updateAnnotations() {
        if mapMode == .viewTrips {
            mainMapView.removeAnnotations(mainMapView.annotations)
            for trip in curTripLocations {
                let coordinate = trip.coordinate
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotation.title = trip.title
                mainMapView.addAnnotation(annotation)
            }
            print("finish adding new annotations")
        }
    }
    
    // Function to set the map region to fit all trip coordinates
    func setRegionToFitTrips() {
        if mapMode == .viewTrips {
            print("setting region")
            guard !self.curTripLocations.isEmpty else { return }

            // Find the minimum and maximum latitude and longitude from curTripLocations
            let minLat = self.curTripLocations.map { $0.coordinate.latitude }.min()!
            let maxLat = self.curTripLocations.map { $0.coordinate.latitude }.max()!
            let minLon = self.curTripLocations.map { $0.coordinate.longitude }.min()!
            let maxLon = self.curTripLocations.map { $0.coordinate.longitude }.max()!

            // Calculate the center of the region
            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)

            // Calculate the span (the zoom level) based on the difference between min and max coordinates
            let spanLat = maxLat - minLat
            let spanLon = maxLon - minLon
            let span = MKCoordinateSpan(latitudeDelta: spanLat * 1.2, longitudeDelta: spanLon * 1.2) // Add some padding (1.2 multiplier)

            // Set the region
            let region = MKCoordinateRegion(center: center, span: span)
            mainMapView.setRegion(region, animated: true)
        }
        
    }


}
