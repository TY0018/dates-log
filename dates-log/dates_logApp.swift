//
//  dates_logApp.swift
//  dates-log
//
//  Created by Tong Ying on 6/9/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

//initialise firebase app
class AppDelegate: NSObject, UIApplicationDelegate {
    var authManager:AuthenticationManager = AuthenticationManager.shared
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //Restore previous signed in state
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state.
              self.authManager.currentUser = nil
          } else {
            // Show the app's signed-in state.
              let user = user
              self.authManager.currentUser = user
          }
        }
        return true
    }
    
    
    func application(_ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
          var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }
          return false
    }
}

@main
struct dates_logApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager:AuthenticationManager = AuthenticationManager.shared
    
    init(){
        UITabBar.setTabBarAppearance()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)                
                .onOpenURL { url in GIDSignIn.sharedInstance.handle(url)}
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn{user, error in
                        if error != nil {print(error ?? "No previously signed in user.")}
                        else {
                            guard let user = user else {return}
                            self.authManager.currentUser = user
                        }
                    }
                }
        }
    }
}
