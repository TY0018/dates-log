//
//  FloatingButtonView.swift
//  dates-log
//
//  Created by Tong Ying on 10/9/24.
//

import SwiftUI
import Foundation

//To add new date to any trip
struct FloatingButton: View {
    
    var body: some View {

        Image(systemName: "plus")
            .font(.system(size: 24))
            .foregroundColor(.white)
            .padding()
            .background(Color("MainPurple"))
            .clipShape(Circle())
            .shadow(radius: 10)
        
        .padding()
    }
}

#Preview {
    FloatingButton()
}
