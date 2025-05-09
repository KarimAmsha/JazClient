//
//  CustomListItem.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct CustomListItem<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: Image
    let action: () -> Void
    let textColor: Color?
    let content: Content
    @State private var isToggled = false

    init(title: String, subtitle: String, icon: Image, action: @escaping () -> Void, textColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.textColor = textColor
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        icon
                            .foregroundColor(.primaryBlack())
                        Text(title)
                        Spacer()
//                        if title == LocalizedStringKey.notifications {
//                            Toggle("", isOn: $isToggled)
//                                .padding()
//                                .toggleStyle(CustomToggleStyle())
//                                .onChange(of: isToggled) { newValue in
////                                    updateAvailability(newValue)
//                                }
//                        } else {
                            Image(systemName: "chevron.left")
//                        }
                    }
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(textColor ?? .primaryBlack())
                    .padding(.leading, 14)
                }
            }
            
            CustomDivider(color: .grayF2F2F2())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
