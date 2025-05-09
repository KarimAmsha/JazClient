//
//  CustomTextFieldWithTitle.swift
//  Khawi
//
//  Created by Karim Amsha on 28.10.2023.
//

import SwiftUI

struct CustomTextFieldWithTitle: View {
    @Binding var text: String

    var placeholder: String
    var textColor: Color
    var placeholderColor: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(Color.grayF9FAFA())
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.grayE6E9EA(), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 0) {
                Text(placeholder)
                    .customFont(weight: .bold, size: 11)
                    .foregroundColor(placeholderColor)
                    .padding(.horizontal, 20)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(placeholderColor)
                            .frame(alignment: .leading)
                            .padding(.horizontal, 20)
                    }
                    
                    TextField("", text: $text)
                        .customFont(weight: .bold, size: 16)
                        .foregroundColor(textColor)
                        .accentColor(Color.primary())
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    CustomTextFieldWithTitle(text: .constant("Text"), placeholder: "Text", textColor: .black, placeholderColor: .gray)
}
