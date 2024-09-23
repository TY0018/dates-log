//
//  AddLogView.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import MapKit

struct AddLogView: View {
    @Binding var confirm: Bool
    @EnvironmentObject var locationManager:LocationManager
    @ObservedObject var viewModel:AddLogMapViewViewModel
    
    var body: some View {
        if let place = locationManager.pickedPlaceMark {
            confirmLocationView(place:place)
        } else {
            Text("Fetching location...")
        }
        
    }
    
    @ViewBuilder
    func confirmLocationView(place:CLPlacemark) -> some View {
        NavigationStack{
            VStack(spacing:15){
//                Text("Confirm Location")
                    
                HStack(spacing: 15){
                    Image(systemName:"mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    VStack(alignment:.leading, spacing: 6){
                        Text(place.name ?? "")
                            .font(.title3.bold())
                        Text(place.thoroughfare ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment:.leading)
                .padding(.vertical, 10)
                NavigationLink(destination: AddDetailsView(viewModel: viewModel, place: place)
                                .navigationTitle("Add Details")
                                .bold()) {
                                Text("Confirm Location")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color("MainPurple"))
                                    }
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "arrow.right")
                                            .font(.title3.bold())
                                            .padding(.trailing)
                                    }
                                    .foregroundColor(.white)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                // Update the view model with the selected place
                                viewModel.placeLocation = place.location
                                viewModel.placeName = place.name ?? ""
                            })
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
            .navigationTitle("Confirm Location")
                .bold()
        }
        
        .padding()
    }
}
//Second sheet to fill in date details
struct AddDetailsView: View {
    @StateObject var userManager = UserManager.shared
    @ObservedObject var viewModel:AddLogMapViewViewModel
    @State private var isCreatingNewGroup: Bool = false
    @State var showPicker: Bool = false
    
    var place:CLPlacemark?
    
    var body: some View{
        ScrollView{
            VStack(spacing:15){
                VStack(alignment:.leading, spacing: 6){
                    Text("Location")
                        .font(.headline)
                        .foregroundStyle(Color("MainPurple"))
                        .frame(maxWidth: .infinity, alignment:.leading)
                    HStack{
                        Text(place?.name ?? "")
                            .font(.title3.bold())
                        Spacer()
                        Image(systemName: viewModel.isFavourite ? "suit.heart.fill" : "suit.heart")
                            .font(.title)  // Adjust the font size as needed
                            .foregroundColor(viewModel.isFavourite ? .pink : .gray)  // Change color based on state
                            .onTapGesture {
                                // Toggle the heart image state
                                viewModel.setFav(!viewModel.isFavourite)
                            }
                    }
                    .padding()
                    .frame(maxWidth:.infinity)
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
                .sheet(isPresented: $isCreatingNewGroup){
                    AddNewGroupView(isPresented: $isCreatingNewGroup, curGroupName: $viewModel.group)
                        .presentationDetents([.medium])
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
            .padding(.horizontal, 2)
            Button{
                //Add to trip in firebase
                viewModel.saveDate()
                //close the sheet and navigate back to main map view
                viewModel.checkConfirm = false
                viewModel.finishAdding = true
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
            .padding()
            .frame(maxWidth:.infinity,maxHeight:.infinity)
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity, alignment:.leading)
    }
}

struct AddNewGroupView: View {
    @Binding var isPresented: Bool
    @Binding var curGroupName: String
    @State var groupName: String = ""
    @StateObject var userManager:UserManager = UserManager.shared
    var body: some View {
        VStack(spacing:15) {
            Text("Create New Group")
                .font(.title2.bold())
            TextField("New group name:", text: $groupName)
            Button {
                //add new group to db
                userManager.createNewGroup(groupName: groupName)
                // Set the current group to the newly created group
                curGroupName = groupName
                isPresented = false

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
        .frame(maxWidth:.infinity, alignment:.bottom)
    }
}
#Preview {
    AddLogView(confirm: .constant(true), viewModel:AddLogMapViewViewModel())
    .environmentObject(LocationManager.shared)
}


