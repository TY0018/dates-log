//
//  AddLogDetailsOverlayView.swift
//  dates-log
//
//  Created by Tong Ying on 11/1/25.
//

import Foundation
import SwiftUI
import MapKit

//Overlay to fill in date details
struct AddDetailsView: View {
    @StateObject var userManager = UserManager.shared
    @ObservedObject var viewModel:AddLogMapViewViewModel
    @State var showPicker: Bool = false
    
    var place:CLPlacemark?
    
    var body: some View{
        ZStack{
            Color.white
                .ignoresSafeArea() // Ensure it covers the entire screen
            ScrollView{
                VStack{
                    //page title
                    HStack(spacing:20){
                        Button {
                            viewModel.openAddDetailsPage = false
                            //reopen confirmLocation sheet
                            viewModel.openCheckConfirmSheet = true
                        } label: {
                            Image(systemName: "xmark")
                        }
                        Text("Add details")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2.bold())
                    .padding(.top, 40)
                    .padding(.horizontal, -10)
                    
                    Spacer()
                    
                    VStack(spacing:15){
                        VStack(alignment:.leading, spacing: 6){
                            Text("Location")
                                .font(.headline)
                                .foregroundStyle(Color("MainPurple"))
                                .frame(maxWidth: .infinity, alignment:.leading)
                                .padding(.top, 3)
                                Text(place?.name ?? "")
                                    .font(.title3.bold())
                        }
                        VStack(alignment:.leading, spacing: 6){
                            Text("Friend group")
                                .font(.headline)
                                .foregroundStyle(Color("MainPurple"))
                                .frame(maxWidth:.infinity, alignment:.leading)
                            Picker("Select a group", selection: $viewModel.group) {
                                //default text
                                Text("No group selected").tag("No group selected" as String)
                                //list of existing groups
                                ForEach(userManager.groups, id: \.self) { group in
                                    if group != "Favourites" {
                                        Text(group).tag(group as String)
                                    }
                                }
                                
                                // Add a "Create New Trip" option at the end
                                HStack{
                                    Image(systemName: "plus")
                                    Spacer()
                                    Text("Create New Group")
                                }
                                .frame(maxWidth:.infinity)
                                .tag("Create New Group" as String)
                            }
                            .pickerStyle(.menu)

                            .frame(maxWidth:.infinity)
                            .padding()
                            .onChange(of: viewModel.group) {
                                if viewModel.group == "Create New Group" {
                                    //create new group
                                    viewModel.openCreateNewGroupPopUp = true
                                }
                            }
                        }
                        .frame(maxWidth:.infinity)
                        .onAppear {
                            userManager.fetchGroups()
                        }
                        VStack (alignment:.leading, spacing: 6) {
                            Text("Title")
                                .font(.headline)
                                .foregroundStyle(Color("MainPurple"))
                                .frame(maxWidth: .infinity, alignment:.leading)
                            TextField("Title of Date", text: $viewModel.title)
                                .padding(5)
                                .frame(maxWidth:.infinity)
                                .overlay(
                                     RoundedRectangle(cornerRadius: 10)
                                       .stroke(Color("MainPurple"), lineWidth: 2)
                                 )
                        }
                        VStack(alignment:.leading, spacing: 6){
                            Text("Date")
                                .font(.headline)
                                .foregroundStyle(Color("MainPurple"))
                                .frame(maxWidth: .infinity, alignment:.leading)
                            DateTextField(date: $viewModel.date, showPicker: $showPicker, title: "Select Date")
                                .sheet(isPresented: $showPicker) {
                                    DatePicker("Select Date", selection: $viewModel.date, displayedComponents: [.date])
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .padding()
                                    Button{
                                        showPicker = false
                                    } label: {
                                        ZStack{
                                            Text("Done")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .fill(Color("MainPurple"))
                                                }
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                    }
                                    .presentationDetents([.medium])
                                }
                        }
                        VStack(alignment:.leading, spacing: 6) {
                            Text("Rating: \(Int(viewModel.rating))")
                                .foregroundStyle(Color("MainPurple"))
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment:.leading)
                            Slider(value: $viewModel.rating, in: 1...5, step: 1)
                                .padding()
                        }
                        
                        // TextBox
                        VStack (alignment:.leading, spacing: 6) {
                            Text("Description")
                                .font(.headline)
                                .foregroundStyle(Color("MainPurple"))
                                .frame(maxWidth: .infinity, alignment:.leading)
                            TextEditor(text: $viewModel.description)
                                .frame(maxWidth:.infinity, minHeight: 100)
                                .overlay(
                                         RoundedRectangle(cornerRadius: 10)
                                           .stroke(Color("MainPurple"), lineWidth: 2)
                                         )
                        }
                        
                    }
                    
                    Spacer()
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth:.infinity)
                    }
                    Button{
                        //Add to trip in firebase
                        viewModel.saveDate()
                    } label: {
                        Text("Add event")
                            .fontWeight(.semibold)
                            .frame(maxWidth:.infinity)
                            .padding(.vertical, 12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style:.continuous)
                                    .fill(viewModel.canSave ? Color("MainPurple") : Color.gray)
                            }
                            .foregroundColor(.white)
                    }
                    .disabled(!viewModel.canSave) // Disable button until all required fields are filled
//                    .padding()
                    .frame(maxWidth:.infinity,maxHeight:.infinity)
                }
                .padding(30)
            }
            //show CreateNewGroupPopUp
            if viewModel.openCreateNewGroupPopUp {
                CreateNewGroupPopupView(isPresented: $viewModel.openCreateNewGroupPopUp, curGroupName: $viewModel.group)
                    .transition(.scale)
            }
        }
//        .alert(item: $viewModel.errorMessage) {
//            errorMessage in
//            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")){
////                viewModel.errorMessage = nil
//            })
//        }
        .navigationBarHidden(true) // Hides navigation bar
        .frame(maxWidth:.infinity,maxHeight:.infinity, alignment:.leading)
    }
}
