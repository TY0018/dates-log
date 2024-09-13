//
//  LogInViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import Foundation

class MainMapViewViewModel: ObservableObject {
    @Published var currentGroup: String = "No group selected"
    @Published var showTripDetails: Bool = false
    init(){}
    
}
