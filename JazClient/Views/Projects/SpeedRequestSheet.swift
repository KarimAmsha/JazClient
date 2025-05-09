//
//  SpeedRequestSheet.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct SpeedRequestSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        ModalTemplate(
            title: "طلب تسريع التسليم",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("يرجى توضيح سبب طلب التسريع إن وجد.")
                    TextEditor(text: .constant(""))
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    Spacer()
                    Button("إرسال الطلب") {
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
