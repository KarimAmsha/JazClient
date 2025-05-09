//
//  OrderItemView.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct OrderItemView: View {
    let item: OrderModel
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AsyncImageView(
                    width: 60,
                    height: 60,
                    cornerRadius: 5,
                    imageURL: item.items?.first?.image?.toURL(),
                    placeholder: Image(systemName: "photo"),
                    contentMode: .fill
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.orderNo ?? "")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.primaryBlack())
                    
                    HStack {
                        Text(item.formattedCreateDate ?? "")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.primaryBlack())
                        
                        Spacer()
                        
                        Text(item.orderStatus?.value ?? "")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.orangeF7941D())
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.orangeF7941D().opacity(0.2).clipShape(Capsule()))
                    }
                }
            }
            .padding(.vertical, 8)
            .onTapGesture {
                onSelect()
            }
        }
    }
}
