//
//  Text+Extensions.swift
//  Fazaa
//
//  Created by Karim Amsha on 13.02.2024.
//

import SwiftUI

extension Text {
    func styledText(text: String,
                    fontWeight: FontWeight = .regular,
                    fontSize: CGFloat = 12,
                    textColor: Color = .black) -> some View {
        return self
            .customFont(weight: fontWeight, size: fontSize)
            .foregroundColor(textColor)
    }
}
