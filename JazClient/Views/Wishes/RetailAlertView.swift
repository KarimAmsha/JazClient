//
//  RetailAlertView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct RetailAlertView: View {
    let onSelect: (Bool) -> Void
    let onCancel: () -> Void
    @State var isAccepted: Bool = false
    @State var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("هل تريد أن تتبع هذه الأمنية نظام “القَطَّة”؟")
                    .customFont(weight: .bold, size: 14)
                Spacer()
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black121212())
                }
            }
            
            Text("نظام القَطَّة هي طريقة تسهل عليك تحقيق الامنية الخاصة بك من خلال السماح للاخرين داخل التطبيق بان يساهموا في تحقيق الامنية الخاصة بك!")
                .customFont(weight: .regular, size: 12)
                .foregroundColor(.black121212())

            HStack(alignment: .center) {
                Checkbox(isChecked: $isAccepted)
                    .frame(width: 20, height: 20)
                
                Text("يجب الموافقة على سياسة وأحكام الخصوصية الخاصة بهذه الميزة وما يتبعها،")
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.black)
            }
            
            if !isAccepted && !alertMessage.isEmpty  {
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

            HStack(spacing: 20) {
                Button {
                    guard isAccepted else {
                        alertMessage = "يجب الموافقة على سياسة واحكام هذه الميزة"
                        return
                    }

                    withAnimation {
                        onSelect(true)
                        alertMessage = ""
                    }
                } label: {
                    Text("نعم اريد!")
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryLightHover(), foreground: .primary1(), height: 48, radius: 12))
                
                Button {
                    withAnimation {
                        onSelect(false)
                        alertMessage = ""
                    }
                } label: {
                    Text("لا٬ اضف الامنية فقط")
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryLightHover(), foreground: .primary1(), height: 48, radius: 12))
            }
        }
        .frame(height: 200)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

#Preview {
    RetailAlertView(onSelect: {_ in}, onCancel: {})
}

struct Checkbox: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .resizable()
            .foregroundColor(isChecked ? .primary1() : .gray)
            .onTapGesture {
                isChecked.toggle()
            }
    }
}
