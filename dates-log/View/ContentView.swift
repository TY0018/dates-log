//
//  ContentView.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var authManager:AuthenticationManager
    
    var body: some View {
        if authManager.currentUser == nil {
            LoginView()
        } else {
            MainView()
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager.shared)
}
