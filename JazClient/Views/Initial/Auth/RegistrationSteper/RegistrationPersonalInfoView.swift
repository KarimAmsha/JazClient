//
//  RegistrationPersonalInfoView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct RegistrationPersonalInfoView: View {
    @State private var gender: String = "male"
    @State private var fullName: String = ""
    @State private var phone: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            RegistrationStepHeader(
                title: "المعلومات الشخصية",
                subtitle: "يرجى تعبئة البيانات الشخصية بدقة لضمان إنشاء الحساب."
            )

            HStack(spacing: 100) {
                GenderOption(title: "ذكر", selected: $gender, value: "male")
                GenderOption(title: "أنثى", selected: $gender, value: "female")
            }

            TextField("الاسم الكامل", text: $fullName)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

            HStack {
                Text("+966")
                    .padding()
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                TextField("رقم الهاتف", text: $phone)
                    .padding()
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
            }
            .frame(height: 48)

            Spacer()
        }
        .padding()
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    RegistrationPersonalInfoView()
}

struct GenderOption: View {
    var title: String
    @Binding var selected: String
    var value: String

    var body: some View {
        Button(action: {
            selected = value
        }) {
            HStack {
                Circle()
                    .fill(selected == value ? Color.yellowF8B22A() : Color.yellowFFF3D9())
                    .frame(width: 20, height: 20)
                Text(title)
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.black151515())
            }
        }
    }
}
