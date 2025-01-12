//
//  ProfileView.swift
//  dates-log
//
//  Created by Tong Ying on 9/9/24.
//

import SwiftUI
import Foundation

struct ProfileView: View {
    @EnvironmentObject var authManager:AuthenticationManager
    @EnvironmentObject var userManager:UserManager
    
    var body: some View {
        VStack{
            Image(systemName:"person.circle")
                .resizable()
                .aspectRatio(contentMode:.fit)
                .foregroundColor(Color("MainPurple"))
                .frame(width:125, height:125)
                .padding(.vertical, 30)
            //Info: Name, Email, Member since
            VStack(alignment: .leading, spacing:10){
                HStack {
                    Text("Name: ").bold()
                    Text(userManager.user?.name ?? "Error fetching user details")
                }.padding(.horizontal)
                HStack {
                    Text("Email: ").bold()
                    Text(userManager.user?.email ?? "Error fetching user details")
                }.padding(.horizontal)
            }
            Spacer()
            Button {
                authManager.googleSignout()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius:20)
                        .foregroundColor(.white)
                        .shadow(radius:5)
                    HStack{
                        Image("google-logo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Sign out")
                            .foregroundColor(Color.black)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding()
                }
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true) // Ensure height fits content
            Spacer()
        }
        .padding(.vertical, 80)
    }
}


#Preview {
    ProfileView()
        .environmentObject(UserManager.shared)
        .environmentObject(AuthenticationManager.shared)
}
