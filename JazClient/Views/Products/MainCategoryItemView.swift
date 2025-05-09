//
//  MainCategoryItemView.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct MainCategoryItemView: View {
    let item: MainCategory
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            AsyncImageView(
                width: 20,
                height: 20,
                cornerRadius: 0,
                imageURL: item.image?.toURL(),
                placeholder: Image(systemName: "photo"),
                contentMode: .fill
            )
            .padding(25)
            .background(isSelected ? Color.primary().opacity(0.2) : Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(isSelected ? Color.primary() : Color.grayEBF0FF(), lineWidth: 1))
            .padding(.bottom, 4)
            
            Text(item.title ?? "")
                .customFont(weight: .light, size: 10)
                .foregroundColor(isSelected ? .primary() : .gray9098B1())
        }
        .onTapGesture {
            onSelect()
        }
    }
}
