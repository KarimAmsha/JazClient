//
//  RejectionReasonView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 7.05.2025.
//

import SwiftUI

struct RejectionReasonView: View {
    @Binding var showModal: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("سبب الرفض")
                        .font(.title3).bold()

                    Text("تم رفض هذه الخدمة من قبل العميل للأسباب التالية. الرجاء مراجعة التفاصيل بعناية.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Button(action: { showModal = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }

            Text("• لم يتم تسليم الملفات النهائية بصيغة متفق عليها.")
            Text("• الجودة لا تطابق المعاير المطلوبة.")
            Text("• تأخر في تسليم الخدمة عن الوقت المحدد.")

            Spacer()

            Button(action: {}) {
                Text("فهمت، إغلاق")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.redE50000())
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    RejectionReasonView(showModal: .constant(false))
}
