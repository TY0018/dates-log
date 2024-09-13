//
//  LoginViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    //Singleton pattern: only allow one instance of AuthenticationManager
    static let shared = AuthenticationManager()
    //store the firebase userID
    @Published var currentUser:GIDGoogleUser? = nil
    
    //allow only one way of creating manager instance
    private init(){}
    
    func handleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController()) {signInResult, error in
                guard error == nil else {return}
                guard let result = signInResult else {
                // Inspect error
                    print(error?.localizedDescription ?? "Error while signing in")
                  return
              }
              // If sign in succeeded, display the app's main content View.
            print("succeed in signing in")
                //Logging user into firebase
            result.user.refreshTokensIfNeeded { user, error in
                    guard error == nil else { return }
                    guard let user = user else { return }
                    self.logGoogleUser(user: user)
                
                // check if user exists in db
                let db = Firestore.firestore()
                if let user = Auth.auth().currentUser {
                    // User is authenticated, proceed with Firestore read/write
                    let userDocRef = db.collection("users").document(user.uid)
                    userDocRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                print("User already exists")
                            } else {
                                // Document doesn't exist, so insert a new user record
                                self.insertUserRecord(
                                    uId: user.uid,
                                    tokenId: self.currentUser?.idToken?.tokenString ?? "",
                                    name: user.displayName ?? "",
                                    email: user.email ?? ""
                                )
                            }
                        }
                } else {
                    // No user is signed in
                    print("User is not authenticated, unable to add user into db.")
                }
            }
        }
    }
    
    private func logGoogleUser(user: GIDGoogleUser){
        Task {
            do{
                print("Trying to sign in!")
                guard let idToken = user.idToken else {return}
                let accessToken = user.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                try await Auth.auth().signIn(with:credential)
                print("Success Google sign in!")
                await MainActor.run{self.currentUser = user}
            } catch {
                print(error)
            }
        }
    }
    
    //create user in firestore
    private func insertUserRecord(uId: String, tokenId: String, name: String, email: String){
        let db = Firestore.firestore()
        let newUser = User(uId: uId,
                           tokenId: tokenId,
                          name: name,
                          email: email
                    )

        db.collection("users")
            .document(uId)
            .setData(newUser.asDictionary())
    }
    
    //handle error
//    func handleError(error:Error)async{
//        await MainActor.run(body:{
//            errorMessage = error.localizedDescription
//            showError.toggle()
//        })
//    }
//    
    func googleSignout() {
        GIDSignIn.sharedInstance.signOut()
        self.currentUser = nil
        print("Google sign out")
    }
}
