//
//  CustomFont.swift
//  Khawi
//
//  Created by Karim Amsha on 20.10.2023.
//

import SwiftUI

struct CustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    var weight: FontWeight
    var size: CGFloat

    func body(content: Content) -> some View {
        return content.font(Font.custom(
                                weight.rawValue,
                                size: size))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont(
        weight: FontWeight = .regular,
        size: CGFloat) -> some View {
        return self.modifier(CustomFont(weight: weight, size: size))
    }
}
