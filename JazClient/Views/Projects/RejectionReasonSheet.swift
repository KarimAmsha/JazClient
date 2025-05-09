//
//  RejectionReasonSheet.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct RejectionReasonSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        ModalTemplate(title: "سبب الرفض", content: {
            VStack(alignment: .leading, spacing: 12) {
                Text("تم رفض الخدمة من قبل الفريلانسر للأسباب التالية:")
                Text("• الملفات غير مكتملة")
                Text("• الجودة غير مطابقة")

                Spacer()

                Button("فهمت، إغلاق") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.redE50000())
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }, onClose: {
            isPresented = false
        })
    }
}
