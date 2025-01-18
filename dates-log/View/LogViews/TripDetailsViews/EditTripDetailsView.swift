//
//  EditTripDetailsView.swift
//  dates-log
//
//  Created by Tong Ying on 7/1/25.
//

import Foundation

import SwiftUI

struct EditTripDetailsInstanceView: View {
    @Binding var selectedDetent: PresentationDetent
    @ObservedObject var viewModel: EditTripDetailsInstanceViewViewModel
    @StateObject var userManager = UserManager.shared
    @State private var isCreatingNewGroup: Bool = false
    @State var showPicker: Bool = false
    @Environment(\.dismiss) private var dismiss // Add dismiss environment

    var body: some View{
        VStack{
            GeometryReader { geometry in
                ScrollView{
                    VStack(alignment:.leading, spacing:15){
                        // Location Section
                        Text("\(viewModel.placeName) - \( viewModel.group)")
                            .font(.subheadline)
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
                            }
                            .frame(maxWidth:.infinity)
                        }
                        
                        //Date Section
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
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Button{
                        viewModel.saveChanges()
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
                .frame(maxWidth:.infinity,maxHeight: geometry.size.height, alignment:.leading)
            }
            
        }
        .onChange(of:viewModel.hasError){
            if !viewModel.hasError {
                dismiss()
            }
        }
//        .onChange(of: selectedDetent, initial: true) {
//            // Trigger a layout update when the detent changes
//            print("Sheet detent changed to \(selectedDetent)")
//        }
    }
}

//#Preview {
//    let viewModel = EditTripDetailsInstanceViewViewModel(dateInstance: DateInstance(title: "title", description: "description", rating: 3, date: Date(), isFavourite: true))
//    return EditTripDetailsInstanceView(viewModel: viewModel)
//}
