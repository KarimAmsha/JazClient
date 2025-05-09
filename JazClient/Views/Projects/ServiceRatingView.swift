//
//  ServiceRatingView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 7.05.2025.
//

import SwiftUI

struct ServiceRatingView: View {
    @State private var rating: Int = 5
    @State private var feedback: String = ""
    @Binding var showModal: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("تقييم الخدمة")
                        .font(.title3).bold()

                    Text("قم بإضافة تقييم واقعي وصريح لعميلك، هذا يساعدنا على تحسين تجربة المستخدمين لجميع الأطراف وضمان الحقوق!")
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

            Text("التقييم من 5")
                .font(.callout)

            HStack {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.orange)
                        .onTapGesture {
                            rating = i
                        }
                }
            }

            Text("تفاصيل التقييم")
                .font(.subheadline)
                .bold()

            TextEditor(text: $feedback)
                .frame(height: 120)
                .padding(8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Spacer()

            Button(action: {}) {
                Text("حفظ التقييم!")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    ServiceRatingView(showModal: .constant(false))
}
