//
//  RegistrationRoleView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

// MARK: - Enum for Roles

enum UserRole: String {
    case provider
    case client
}

// MARK: - Registration Role View

struct RegistrationRoleView: View {
    @Binding var selectedRole: UserRole?

    var body: some View {
        VStack(spacing: 24) {
            RegistrationStepHeader(
                title: "مقدمة خدمة أم عميل؟",
                subtitle: "هل تقدم خدمات معينة أم تحتاج إلى توظيف محترفين؟"
            )

            VStack(spacing: 16) {
                RoleCardView(
                    icon: "person.fill",
                    title: "مقدم خدمة",
                    description: "ستكون قادر على عرض اعمالك وتلقي العروض من العملاء عبر المنصة.",
                    selected: selectedRole == .provider
                ) {
                    selectedRole = .provider
                }
                .frame(maxWidth: .infinity)

                RoleCardView(
                    icon: "building.2.fill",
                    title: "صاحب مشاريع",
                    description: "سنساعدك في اختيار أفضل مقدمين الخدمات والحصول على خدمة مميزة",
                    selected: selectedRole == .client
                ) {
                    selectedRole = .client
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.background())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    RegistrationRoleView(selectedRole: .constant(nil))
}

// MARK: - Reusable Components

struct RegistrationStepHeader: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: "C58B32"))
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RoleCardTestView: View {
    @State private var selectedRole: String? = nil

    var body: some View {
        VStack {
            Button("اختار Provider") {
                selectedRole = "provider"
            }
            RoleCardView(
                icon: "person.fill",
                title: "مقدم خدمة",
                description: "وصف ما",
                selected: selectedRole == "provider"
            ) {}
        }
    }
}

struct RoleCardView: View {
    var icon: String
    var title: String
    var description: String
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .foregroundColor(selected ? .white : .black)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(selected ? Color.yellowF8B22A() : Color.yellowFFF3D9())
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.black.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct PrimaryActionButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary())
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

struct SecondaryActionButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
        }
    }
}
