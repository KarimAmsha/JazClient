//
//  RegistrationIdentityView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct RegistrationIdentityView: View {
    var body: some View {
        VStack(spacing: 24) {
            RegistrationStepHeader(
                title: "اثبات الهوية",
                subtitle: "قم بربط بيانات حساباتك البنكية التي ستتلقى عليها الأرباح مستقبلاً!"
            )

            VStack(spacing: 16) {
                UploadBox(title: "قم بالضغط لرفع صورتك الشخصية")
                UploadBox(title: "قم بالضغط لرفع صورة هويتك")
            }
        }
        .padding()
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct UploadBox: View {
    var title: String

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "camera")
                .font(.system(size: 24))
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
        .cornerRadius(12)
    }
}

#Preview {
    RegistrationIdentityView()
}
