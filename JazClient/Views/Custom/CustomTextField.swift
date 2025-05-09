//
//  CustomTextField.swift
//  Khawi
//
//  Created by Karim Amsha on 23.10.2023.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    
    var placeholder: String
    var textColor: Color
    var placeholderColor: Color
    var backgroundColor: Color = .white

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(backgroundColor, lineWidth: 1)
                )
            
            if text.isEmpty {
                Text(placeholder)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(placeholderColor)
                    .padding(.horizontal, 8)
            }
            
            TextField("", text: $text)
                .customFont(weight: .regular, size: 14)
                .foregroundColor(textColor)
                .accentColor(Color.primary())
                .padding(.horizontal, 8)
        }
    }
}

#Preview {
    CustomTextField(text: .constant("Text"), placeholder: "Text", textColor: .black, placeholderColor: .gray)
}
