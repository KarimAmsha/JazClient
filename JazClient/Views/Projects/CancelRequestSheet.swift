//
//  CancelRequestSheet.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct CancelRequestSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        ModalTemplate(
            title: "طلب الغاء الخدمة",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("ما هو سبب إلغاء الخدمة؟")

                    Picker("سبب الإلغاء", selection: .constant(0)) {
                        Text("اختر سبب الالغاء").tag(0)
                        Text("الخدمة غير مطابقة للوصف").tag(1)
                        Text("تأخر غير مبرر").tag(2)
                    }
                    .pickerStyle(MenuPickerStyle())

                    TextEditor(text: .constant(""))
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )

                    Spacer()

                    HStack {
                        Button("تأكيد إلغاء المشروع") {
                            isPresented = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redE50000())
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("تراجع") {
                            isPresented = false
                        }
                        .frame(width: 80)
                        .foregroundColor(.gray)
                    }
                }
            },
            onClose: {
                isPresented = false
            }
        )
    }
}
