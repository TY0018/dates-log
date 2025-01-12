//
//  EditTripDetailsView.swift
//  dates-log
//
//  Created by Tong Ying on 7/1/25.
//

import Foundation

import SwiftUI

struct EditTripDetailsInstanceView: View {
    
    @ObservedObject var viewModel: EditTripDetailsInstanceViewViewModel
    @StateObject var userManager = UserManager.shared
    @State private var isCreatingNewGroup: Bool = false
    @State var showPicker: Bool = false
    
    var body: some View{
        ScrollView{
            VStack(spacing:15){
                // Location Section
                VStack(alignment:.leading, spacing: 6){
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(Color("MainPurple"))
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding(.top, 3)
                    HStack{
                        TextField("Enter Title", text: $viewModel.title)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("MainPurple"), lineWidth: 2)
                            )
                        Spacer()
                        Image(systemName: viewModel.isFavourite ? "suit.heart.fill" : "suit.heart")
                            .font(.title)  // Adjust the font size as needed
                            .foregroundColor(viewModel.isFavourite ? .pink : .gray)  // Change color based on state
                            .onTapGesture {
                                // Toggle the heart image state
                                viewModel.setFav(!viewModel.isFavourite)
                            }

                    }
//                    .padding()
                    .frame(maxWidth:.infinity)
                }
                //Group Section
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
                        Text("Create New Group").tag("Create New Group" as String)
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .frame(maxWidth:.infinity)
                    .padding()
                    .onChange(of: viewModel.group) {
                        if viewModel.group == "Create New Group" {
                            //create new group
                            isCreatingNewGroup = true
                        }
                    }
                }
                .frame(maxWidth:.infinity)
                .onAppear {
                    userManager.fetchGroups()
                }
                .sheet(isPresented: $isCreatingNewGroup, onDismiss: {
                    // Reset the picker selection when sheet is closed
                    viewModel.group = "No group selected"
                }){
                    AddNewGroupView(isPresented: $isCreatingNewGroup, curGroupName: $viewModel.group)
                        .presentationDetents([.medium])
                }
                //Date Section
//                VStack(alignment:.leading, spacing: 6){
//                    Text("Date")
//                        .font(.headline)
//                        .foregroundStyle(Color("MainPurple"))
//                        .frame(maxWidth: .infinity, alignment:.leading)
//                    DateTextField(date: $viewModel.date, showPicker: $showPicker, title: "Select Date")
//                        .sheet(isPresented: $showPicker) {
//                            DatePicker("Select Date", selection: $viewModel.date, displayedComponents: [.date])
//                                .datePickerStyle(GraphicalDatePickerStyle())
//                                .padding()
//                            Button{
//                                showPicker = false
//                            } label: {
//                                ZStack{
//                                    Text("Done")
//                                        .fontWeight(.semibold)
//                                        .frame(maxWidth: .infinity)
//                                        .padding(.vertical, 12)
//                                        .background {
//                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                                .fill(Color("MainPurple"))
//                                        }
//                                        .foregroundColor(.white)
//                                }
//                                .padding()
//                            }
//                            .presentationDetents([.medium])
//                        }
//                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Date")
                        .font(.headline)
                        .foregroundStyle(Color("MainPurple"))
                    DatePicker(
                        "Select Date",
                        selection: $viewModel.date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                //Rating Section
                VStack(alignment:.leading, spacing: 6) {
                    Text("Rating: \(Int(viewModel.rating))")
                        .foregroundStyle(Color("MainPurple"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment:.leading)
                    Slider(value: $viewModel.rating, in: 1...5, step: 1)
                        .padding()
                }
                
                //Description Section
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
            .padding(.horizontal)
            Button{
                print("Changes saved!")
//                Task {
//                    await viewModel.saveChanges(groupName: viewModel.group)
//                }
            } label: {
                Text("Save changes")
                    .fontWeight(.semibold)
                    .frame(maxWidth:.infinity)
                    .padding(.vertical, 12)
                    .background{
                        RoundedRectangle(cornerRadius: 10, style:.continuous)
                            .fill(viewModel.canSave ? Color("MainPurple") : Color.gray)
                    }
                    .foregroundColor(.white)
            }
            .disabled(!viewModel.canSave) // Disable button unless all required fields are filled
            .padding()
            .frame(maxWidth:.infinity,maxHeight:.infinity)
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity, alignment:.leading)
    }
}

//#Preview {
//    let viewModel = EditTripDetailsInstanceViewViewModel(dateInstance: DateInstance(title: "title", description: "description", rating: 3, date: Date(), isFavourite: true))
//    return EditTripDetailsInstanceView(viewModel: viewModel)
//}
