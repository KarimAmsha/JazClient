//
//  EditGroupView.swift
//  Wishy
//
//  Created by Karim Amsha on 12.06.2024.
//

import SwiftUI

struct EditGroupView: View {
    @Binding var name: String
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black121212())
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey.groupName)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.black1F1F1F())
                CustomTextField(text: $name, placeholder: LocalizedStringKey.groupName, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
            }

            Button {
                withAnimation {
                    onSelect()
                }
            } label: {
                Text(LocalizedStringKey.saveGroup)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}
