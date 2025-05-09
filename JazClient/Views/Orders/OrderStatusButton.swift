//
//  OrderStatusButton.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct OrderStatusButton: View {
    var title: String
    @State var status: OrderStatus
    @Binding var selectedStatus: OrderStatus

    var body: some View {
        Button {
            withAnimation {
                selectedStatus = status
            }
        } label: {
            HStack {
                Spacer()
                Text(title)
                Spacer()
            }
            .customFont(weight: selectedStatus == status ? .bold : .regular, size: 12)
            .foregroundColor(selectedStatus == status ? .white : .black121212())
        }
        .buttonStyle(GradientPrimaryButton(
            fontSize: 12,
            fontWeight: .bold,
            background: selectedStatus == status ? Color.primaryGradientColor() : Color.grayGradientColor(),
            foreground: .black121212(),
            height: 40,
            radius: 8
        ))
        .frame(maxWidth: .infinity) // Make the button take up all available width
    }
}

