//
//  MobileView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import Combine

struct MobileView: View {
    @FocusState private var keyIsFocused: Bool
    @Binding var mobile: String
    @Binding var presentSheet: Bool
    @State var countryCode : String = "+966"
    @State var countryFlag : String = "🇸🇦"
    @State var countryPattern : String = "## ### ####"
    @State var countryPatternPalceholder : String = "5# ### ####"
    @State var strokeColor = Color.primaryGreen()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey.phoneNumber)
                .customFont(weight: .medium, size: 12)
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                Button {
                    presentSheet = true
                    keyIsFocused = false
                } label: {
                    Text("\(countryFlag) \(countryCode)")
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.primaryBlack())
                }
                
                TextField(countryPatternPalceholder, text: $mobile)
                    .placeholder(when: mobile.isEmpty) {
                        Text(countryPatternPalceholder)
                            .foregroundColor(.gray999999())
                    }
                    .focused($keyIsFocused)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.black1C2433())
                    .keyboardType(.phonePad)
                    .onReceive(Just(mobile)) { _ in
                        applyPatternOnNumbers(&mobile, pattern: countryPattern, replacementCharacter: "#")
                    }
                    .accentColor(.primary())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .roundedBackground(cornerRadius: 8, strokeColor: strokeColor, lineWidth: 1)
            .environment(\.layoutDirection, .leftToRight)
        }
    }
    
    func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
    }
}
