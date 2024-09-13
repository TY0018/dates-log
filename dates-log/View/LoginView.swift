//
//  LogInView.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct LoginView: View {
    @EnvironmentObject var authManager:AuthenticationManager
    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome")
                .font(.largeTitle)
                .bold()
            Text("Sign in to begin!")
                .font(.title3)
//           GoogleSignInButton(action:authManager.handleSignInButton)
            SignInButton()
            Spacer()
            
        }
    }
    
    @ViewBuilder
    func SignInButton() -> some View {
            Button {
                authManager.handleSignInButton()
            } label : {
                ZStack {
                    RoundedRectangle(cornerRadius:20)
                        .foregroundColor(.white)
                        .shadow(radius:5)
                    HStack{
                        Image("google-logo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Sign in with Google")
                            .foregroundColor(Color.black)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding()
                    
                }.padding()
            }
            .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true) // Ensure height fits content
    }
}



#Preview {
    LoginView()
        .environmentObject(AuthenticationManager.shared)
}
