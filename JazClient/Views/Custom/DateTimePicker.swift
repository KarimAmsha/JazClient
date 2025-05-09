//
//  DateTimePicker.swift
//  Wishy
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI

struct DateTimePicker: View {
    @State var selectedDate = Date()
    let model: DateTimeModel

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Button(LocalizedStringKey.cancel) {
                    withAnimation {
                        model.onCancelAction()
                    }
                }
                .buttonStyle(PopOverButtonStyle())
                Spacer()
                Button(LocalizedStringKey.done) {
                    model.onOKAction(selectedDate)
                }
                .buttonStyle(PopOverButtonStyle())
            }
            .padding([.leading, .trailing], 20)

            if model.pickerMode == .date {
                DatePicker(LocalizedStringKey.date, selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding(.bottom, -40)
                    .transition(.opacity)
                    .environment(\.locale, Locale.init(identifier: "en"))
            } else {
                DatePicker(LocalizedStringKey.time, selection: $selectedDate, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding(.bottom, -40)
                    .transition(.opacity)
                    .environment(\.locale, Locale.init(identifier: "en"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

