//
//  DateTextFieldView.swift
//  dates-log
//
//  Created by Tong Ying on 12/9/24.
//

import SwiftUI

struct DateTextField: View {
    @Binding var date: Date
    @Binding var showPicker: Bool
    
    var title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(date, style: .date)
                .foregroundColor(.gray)
                .onTapGesture {
                    showDatePicker()
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
//        .padding(.horizontal)
    }


    private func showDatePicker() {
        showPicker = true
    }
}
