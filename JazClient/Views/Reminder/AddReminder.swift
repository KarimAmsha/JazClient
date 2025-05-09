//
//  AddReminder.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI
import PopupView

struct AddReminder: View {
    @State var title = ""
    @State private var dateStr: String = ""
    @State private var date: Date = Date()
    @State private var isShowingDatePicker = false
    @State var before = ""
    let onSelect: (String, String, String) -> Void
    let onClose: () -> Void
    @State var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(LocalizedStringKey.addNewReminder)
                    .customFont(weight: .bold, size: 14)
                Spacer()
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black121212())
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey.reminderTitle)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.black1F1F1F())
                CustomTextField(text: $title, placeholder: LocalizedStringKey.reminderTitle, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
            }
            
            VStack(alignment: .leading) {
                Text(LocalizedStringKey.reminderDate)
                    .customFont(weight: .medium, size: 12)

                HStack {
                    TextField(LocalizedStringKey.reminderDate, text: $dateStr)
                        .placeholder(when: dateStr.isEmpty) {
                            Text(LocalizedStringKey.reminderDate)
                                .foregroundColor(.gray999999())
                        }
                        .customFont(weight: .regular, size: 14)
                        .disabled(true)

                    Spacer()

                    Image("ic_calendar")
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .roundedBackground(cornerRadius: 12, strokeColor: .black121212(), lineWidth: 1)
                .onTapGesture {
                    isShowingDatePicker = true
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey.reminderBefor)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.black1F1F1F())
                CustomTextField(text: $before, placeholder: LocalizedStringKey.reminderBefor, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                    .keyboardType(.numberPad)
            }

            if !alertMessage.isEmpty {
                HStack {
                    Text(alertMessage)
                        .customFont(weight: .semiBold, size: 12)
                        .foregroundColor(.redCA1616())
                        .padding(4)
                    Spacer()
                }
                .background(Color.red.opacity(0.1))
                .cornerRadius(4)
            }

            Button {
                withAnimation {
                    guard !title.isEmpty, !dateStr.isEmpty, !before.isEmpty else {
                        alertMessage = "جميع الحقول مطلوبة"
                        return
                    }
                    onSelect(title, dateStr, before)
                    alertMessage = ""
                }
            } label: {
                Text(LocalizedStringKey.saveReminder)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .popup(isPresented: $isShowingDatePicker) {
            let dateModel = DateTimeModel(pickerMode: .date) { date in
                self.date = date
                dateStr = date.toString(format: "yyyy-MM-dd")
                isShowingDatePicker = false
            } onCancelAction: {
                isShowingDatePicker = false
            }
            
            DateTimePicker(model: dateModel)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
    }
}

#Preview {
    AddReminder(onSelect: { _, _,_  in }, onClose: {})
}

