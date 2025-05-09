//
//  SpecialtySelectionPopup.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct SpecialtySelectionPopup: View {
    @Binding var isPresented: Bool
    @AppStorage("selectedSpecialty") var selectedSpecialty: String = ""

    let specialties: [Specialty] = [
        Specialty(name: "مصمم", icon: "pencil.and.ruler", color: Color.purple.opacity(0.1)),
        Specialty(name: "مختص مالي", icon: "briefcase", color: Color.blue.opacity(0.1)),
        Specialty(name: "طبيب / ممرض", icon: "cross.case", color: Color.green.opacity(0.1)),
        Specialty(name: "مدرب", icon: "person.2.wave.2", color: Color.orange.opacity(0.1)),
        Specialty(name: "مُعلم", icon: "book", color: Color.teal.opacity(0.1)),
        Specialty(name: "مهندس", icon: "wrench.and.screwdriver", color: Color.indigo.opacity(0.1)),
        Specialty(name: "مطور", icon: "chevron.left.slash.chevron.right", color: Color.red.opacity(0.1)),
        Specialty(name: "مدير", icon: "person.crop.rectangle", color: Color.cyan.opacity(0.1))
    ]

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Text("التخصص الأساسي")
                .font(.title3.bold())
                .foregroundColor(.primary)

            Text("اختر التخصص الذي ستعمل فيه على منصتنا")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(specialties, id: \.name) { item in
                    Button {
                        selectedSpecialty = item.name
                        isPresented = false
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(item.color)
                                .cornerRadius(12)

                            Text(item.name)
                                .font(.body.bold())
                                .foregroundColor(.primary)

                            Text("+1500 فريلانسر")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct Specialty {
    let name: String
    let icon: String
    let color: Color
}

#Preview {
    SpecialtySelectionPopup(
        isPresented: .constant(false)
    )
}
