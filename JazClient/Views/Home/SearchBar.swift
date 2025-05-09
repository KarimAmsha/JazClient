//
//  SearchBar.swift
//  Wishy
//
//  Created by Karim Amsha on 29.04.2024.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(LocalizedStringKey.searchForProduct, text: $text)
                .customFont(weight: .regular, size: 14)
                .padding(8)
                .background(.white)
                .foregroundColor(.gray737373())
                .cornerRadius(4)

            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        text = ""
                    }
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
    }
}

struct SearchBar2: View {
    @Binding var text: String
    var onTap: (() -> Void)? = nil // <-- إضافة callback اختياري

    var body: some View {
        HStack {
            TextField(LocalizedStringKey.searchForProduct, text: .constant("")) // مش مربوطة بـ text عشان ما يخزن شيء
                .customFont(weight: .regular, size: 14)
                .padding(8)
                .background(.white)
                .foregroundColor(.gray737373())
                .cornerRadius(4)
                .disabled(true) // 👈 يمنع الكتابة
                .onTapGesture {
                    onTap?() // 👈 يستدعي الفعل الخارجي
                }

            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(8)
        }
        .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
    }
}
