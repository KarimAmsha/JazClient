//
//  AccountSettingsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                settingsRow(title: "تغيير كلمة المرور") {
                    appRouter.navigate(to: .changePassword)
                }
                Divider()
                settingsRow(title: "تغيير اسم وصورة العرض") {
                    appRouter.navigate(to: .editProfile)
                }
                Divider()
                settingsRow(title: "تحديث رقم الهاتف") {
                    appRouter.navigate(to: .changePhoneNumber)
                }
//                Divider()
//                settingsRow(title: "تغيير التخصص الرئيسي") {
//                    appRouter.navigate(to: .changeSpecialization)
//                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .background(Color.background())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading) {
                        Text("إعدادات الحساب")
                            .customFont(weight: .bold, size: 20)
                        Text("قم بالتحكم ببيانات الحساب الرئيسية")
                            .customFont(weight: .regular, size: 10)
                    }
                    .foregroundColor(.black222020())
                }
            }
        }
    }

    // ✅ زر إعداد
    @ViewBuilder
    func settingsRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
            }
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
