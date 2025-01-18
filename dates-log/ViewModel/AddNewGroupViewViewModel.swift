//
//  AddNewGroupViewViewModel.swift
//  dates-log
//
//  Created by Tong Ying on 11/10/24.
//

import Foundation

@MainActor
class AddNewGroupViewViewModel: ObservableObject {
    @Published var groupExistsError: Bool = false
    
    init(){}
    
    func createGroup(groupName: String) async {
        do {
            if try await UserManager.shared.checkGroupExists(group: groupName) {
                groupExistsError = true
                return
            }
            groupExistsError = false
            await UserManager.shared.createNewGroup(groupName: groupName)
        } catch {
            print("error when checking/creating groups")
            return
        }
    }
}
