//
//  ProductItemView.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct ProductItemView: View {
    let item: Products
    let onSelect: () -> Void
    let itemHeight: CGFloat = 250  

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(
                width: 150,
                height: 150,
                cornerRadius: 10,
                imageURL: item.image?.toURL(),
                placeholder: Image(systemName: "photo"),
                contentMode: .fill
            )
            .cornerRadius(4)
            .padding(6)
            
            Text(item.name ?? "")
                .customFont(weight: .bold, size: 16)
                .foregroundColor(.primaryBlack())
                .padding(.horizontal, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                RatingView(rating: .constant(item.rate?.toInt() ?? 0))
                HStack {
                    Text(String(format: "%.2f", item.sale_price ?? 0))
                    Text(LocalizedStringKey.sar)
                }
                .customFont(weight: .semiBold, size: 14)
                .foregroundColor(.primary())
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 16)
        }
        .frame(height: itemHeight)
        .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
        .onTapGesture {
            onSelect()
        }
    }
}
