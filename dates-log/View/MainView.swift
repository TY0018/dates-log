//
//  MainView.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var locationManager: LocationManager = LocationManager.shared
    @StateObject var userManager: UserManager = UserManager.shared
    var body: some View {
        TabView{
            MainMapView()
                .environmentObject(locationManager)
                .environmentObject(userManager)
                .tabItem{
                    Label("Map",
                    systemImage: "map.fill")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage:"person.crop.circle.fill")
                }
        }
//        .edgesIgnoringSafeArea(.bottom)
    }
    

}

#Preview {
    MainView()
}
