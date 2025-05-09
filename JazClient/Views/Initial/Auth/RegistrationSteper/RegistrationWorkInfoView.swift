//
//  RegistrationWorkInfoView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI
import PopupView

struct RegistrationWorkInfoView: View {
    @Binding var showSpecialtyPopup: Bool
    @AppStorage("selectedSpecialty") var selectedMainSpecialty: String = ""

    var body: some View {
        VStack(spacing: 24) {
            RegistrationStepHeader(
                title: "تفاصيل العمل",
                subtitle: "قم بإدخال تفاصيل العمل الصحيحة والتي تُجيدها في مجالك للحصول على فرص أعلى."
            )

            VStack(spacing: 16) {
                // اختيار التخصص الأساسي
                VStack(alignment: .leading, spacing: 8) {
                    Text("التخصص الأساسي")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Button {
                        showSpecialtyPopup = true
                    } label: {
                        HStack {
                            Text(selectedMainSpecialty.isEmpty ? "اختر التخصص الاساسي" : selectedMainSpecialty)
                                .foregroundColor(selectedMainSpecialty.isEmpty ? .gray : .primaryBlack())
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                }

                // زر إضافة تخصص آخر
                Button("+ اضافة تخصص اخر") {
                    // لاحقاً يمكن تنفيذ إضافة تخصصات فرعية هنا
                }
                .foregroundColor(Color.orangeD67200())
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding()
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
        .popup(isPresented: $showSpecialtyPopup) {
            SpecialtySelectionPopup(isPresented: $showSpecialtyPopup)
        } customize: {
            $0
                .type(.default)
                .position(.bottom)
                .animation(.easeInOut)
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.3))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
    }
}

#Preview {
    RegistrationWorkInfoView(showSpecialtyPopup: .constant(false))
}
