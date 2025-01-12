//
//  CreateGroupPopupView.swift
//  dates-log
//
//  Created by Tong Ying on 8/1/25.
//

import Foundation
import SwiftUI

struct CreateNewGroupPopupView: View {
    @Binding var isPresented: Bool
    @Binding var curGroupName: String
    @State var groupName: String = ""
    @StateObject var viewModel:AddNewGroupViewViewModel = AddNewGroupViewViewModel()
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all) // Background blur effect
                .onTapGesture {
                    isPresented = false // Dismiss pop-up on tap
                    curGroupName = "No group selected"
                }
            VStack(alignment:.leading, spacing:15) {
                Text("Create New Group")
                    .font(.title2.bold())
                TextField("New group name:", text: $groupName)
                    .padding(5)
                    .overlay(
                             RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.groupExistsError ? Color.red : Color("MainPurple"), lineWidth: 2)
                             )
                // Error Text, shown only when groupExistsError is true
                if viewModel.groupExistsError {
                    Text("Group name already exists, please choose a different name.")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                Button {
                    Task {
                        //add new group to db
                        await viewModel.createGroup(groupName: groupName)
                        
                        if !viewModel.groupExistsError {
                            // Set the current group to the newly created group
                            curGroupName = groupName
                            isPresented = false
                        }

                    }
                } label: {
                    Text("Create group")
                        .fontWeight(.semibold)
                        .frame(maxWidth:.infinity)
                        .padding(.vertical, 12)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style:.continuous)
                                .fill(Color("MainPurple"))
                        }
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(width: 300, height: 200)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        .animation(.easeInOut, value: isPresented)
    }
}

//struct CreateNewGroupPopupView: View {
//    @State private var showPopup = false
//    @Binding var curGroupName: String
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                Text("Main Content")
//                    .font(.largeTitle)
//                Button("Show Pop-Up") {
//                    showPopup = true
//                }
//            }
//            if showPopup {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all) // Background blur effect
//                    .onTapGesture {
//                        showPopup = false // Dismiss pop-up on tap
//                    }
//                PopupView(isPresented: $showPopup, curGroupName: $curGroupName)
//            }
//        }
//        .animation(.easeInOut, value: showPopup)
//    }
//}
