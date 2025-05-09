//
//  EditRequestSheet.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct EditRequestSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        ModalTemplate(
            title: "طلب تعديلات",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("قم باضافة جميع المطلوب تعديله من قبل الفريلانسر بشكل واضح ويمكنك ايضاً استخدام الرسائل المباشرة لطلب التعديلات.")
                    TextEditor(text: .constant(""))
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    Spacer()
                    Button("طلب التعديلات") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            },
            onClose: {
                isPresented = false
            }
        )
    }
}
