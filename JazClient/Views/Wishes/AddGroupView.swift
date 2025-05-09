//
//  AddGroupView.swift
//  Wishy
//
//  Created by Karim Amsha on 12.06.2024.
//

import SwiftUI

struct AddGroupView: View {
    @State var name = ""
    @State var isPublic = true
    let onSelect: (String, String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(LocalizedStringKey.createNewGroup)
                    .customFont(weight: .bold, size: 14)
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

//            VStack(alignment: .leading, spacing: 16) {
//                Text(LocalizedStringKey.privacy)
//                    .customFont(weight: .regular, size: 12)
//                    .foregroundColor(.black1F1F1F())
//                
//                HStack(spacing: 50) {
//                    RadioButton(label: LocalizedStringKey.publicGroup, isSelected: isPublic) {
//                        isPublic = true
//                    }
//                    RadioButton(label: LocalizedStringKey.privateGroup, isSelected: !isPublic) {
//                        isPublic = false
//                    }
//                }
//            }

            Button {
                withAnimation {
                    onSelect(name, isPublic ? "public" : "private")
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

#Preview {
    AddGroupView(name: "", onSelect: { _, _ in }, onClose: {})
}

