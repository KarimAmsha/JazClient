//
//  ButtonsStyles.swift
//  Khawi
//
//  Created by Karim Amsha on 20.10.2023.
//

import SwiftUI

struct GradientPrimaryButton: ButtonStyle {
    var fontSize: CGFloat = 16
    var fontWeight: FontWeight? = .regular
    var background: LinearGradient = Color.primaryGradientColor()
    var foreground: Color = .white
    var height: CGFloat = 48
    var radius: CGFloat = 24

    @Environment(\.sizeCategory) var sizeCategory // Access the current size category

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .center)
            .customFont(weight: fontWeight!, size: adjustedFontSize())
            .foregroundColor(foreground)
            .background(background.cornerRadius(radius))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }

    // Adjust font size based on the size category
    func adjustedFontSize() -> CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return fontSize // No change for smaller sizes
        case .large, .extraLarge:
            return fontSize * 0.9 // Slightly smaller
        case .extraExtraLarge, .extraExtraExtraLarge:
            return fontSize * 0.8 // Smaller
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return fontSize * 0.7 // Much smaller
        @unknown default:
            return fontSize // Fallback to base size
        }
    }
}

struct GradientPrimaryButton2: ButtonStyle {
    var fontSize: CGFloat? = 14
    var fontWeight: FontWeight? = .regular
    var background: LinearGradient? = Color.primaryGradientColor()
    var foreground: Color? = Color.white
    var height: CGFloat? = 48
    var radius: CGFloat? = 24

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .center)
            .customFont(weight: fontWeight!, size: fontSize!)
            .foregroundColor(foreground)
            .background(background.cornerRadius(radius!))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct PrimaryButton: ButtonStyle {
    var fontSize: CGFloat = 14
    var fontWeight: FontWeight? = .regular
    var background: Color? = Color.primary()
    var foreground: Color? = Color.white
    var height: CGFloat? = 48
    var radius: CGFloat? = 24
    @Environment(\.sizeCategory) var sizeCategory // Access the current size category

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .center)
            .customFont(weight: fontWeight!, size: adjustedFontSize())
            .foregroundColor(foreground)
            .background(background.cornerRadius(radius!))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
    
    // Adjust font size based on the size category
    func adjustedFontSize() -> CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return fontSize // No change for smaller sizes
        case .large, .extraLarge:
            return fontSize * 0.9 // Slightly smaller
        case .extraExtraLarge, .extraExtraExtraLarge:
            return fontSize * 0.8 // Smaller
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return fontSize * 0.7 // Much smaller
        @unknown default:
            return fontSize // Fallback to base size
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    var fontSize: CGFloat = 14
    var fontWeight: FontWeight? = .regular
    var background: Color? = Color.primary()
    var foreground: Color? = Color.white
    @Environment(\.sizeCategory) var sizeCategory // Access the current size category

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(6)
            .customFont(weight: fontWeight!, size: adjustedFontSize())
            .background(background)
            .foregroundColor(foreground)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
    
    // Adjust font size based on the size category
    func adjustedFontSize() -> CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return fontSize // No change for smaller sizes
        case .large, .extraLarge:
            return fontSize * 0.9 // Slightly smaller
        case .extraExtraLarge, .extraExtraExtraLarge:
            return fontSize * 0.8 // Smaller
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return fontSize * 0.7 // Much smaller
        @unknown default:
            return fontSize // Fallback to base size
        }
    }
}

struct PopOverButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black141F1F()) // Customize the text color
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Add a pressed effect
    }
}

