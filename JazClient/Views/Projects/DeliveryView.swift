//
//  DeliveryView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 7.05.2025.
//

import SwiftUI

struct DeliveryView: View {
    @State private var files: [String] = ["تصميم بروشور.psd", "تصميم بزنس كارد.psd"]
    @Binding var showModal: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("تسليم الخدمة")
                        .font(.title3).bold()

                    Text("قم بإضافة الرفقات الخاصة بهذه الخدمة حسب متطلبات العميل، تأكد بأن كل المتطلبات مضمنة ضمن هذا التسليم.")
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


            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.doc.fill")
                        .resizable()
                        .frame(width: 32, height: 40)
                        .foregroundColor(.orange)
                    Text("قم بارفاق ملفات التسليم")
                        .font(.headline)
                }
                Text("قم بارفاق جميع الملفات المطلوب تسليمها للعميل، يفضل أن تقوم بتفصيل التسليم حسب المطلوب.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(.gray.opacity(0.4))
            )

            ForEach(files, id: \.self) { file in
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.redE50000())
                    VStack(alignment: .leading) {
                        Text(file).bold()
                        Text("100MB").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
            }

            Spacer()

            Button(action: {}) {
                Text("تسليم الخدمة!")
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
    DeliveryView(showModal: .constant(false))
}
