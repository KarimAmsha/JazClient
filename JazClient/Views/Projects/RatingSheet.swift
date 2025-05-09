//
//  RatingSheet.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct RatingSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        ModalTemplate(
            title: "تقييم الفريلانسر",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("قم باضافة تقييم واقعي وصريح لعميلك، هذا يساعدنا على تحسين تجربة المستخدمين لجيمع الاطراف وضمان الحقوق!")

                    HStack {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                        }
                    }

                    TextEditor(text: .constant(""))
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                    Spacer()

                    Button("حفظ التقييم!") {
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
