//
//  AddFriendView.swift
//  Wishy
//
//  Created by Karim Amsha on 12.06.2024.
//

import SwiftUI
import Combine

struct AddFriendView: View {
    @State var phone = ""
    let onSelect: (String) -> Void
    let onClose: () -> Void
    @State var countryPattern : String = "############"
    @FocusState private var keyIsFocused: Bool
    @State var countryPatternPalceholder : String = "966#########"

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(LocalizedStringKey.addFriend)
                    .customFont(weight: .bold, size: 14)
                Spacer()
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black121212())
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey.phoneNumber)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.black1F1F1F())
                TextField(countryPatternPalceholder, text: $phone)
                    .placeholder(when: phone.isEmpty) {
                        Text(countryPatternPalceholder)
                            .foregroundColor(.gray999999())
                    }
                    .focused($keyIsFocused)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.black1C2433())
                    .keyboardType(.phonePad)
                    .onReceive(Just(phone)) { _ in
                        applyPatternOnNumbers(&phone, pattern: countryPattern, replacementCharacter: "#")
                    }
                    .accentColor(.primary())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
            }

            Button {
                withAnimation {
                    onSelect(phone)
                }
            } label: {
                Text(LocalizedStringKey.add)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
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

#Preview {
    AddFriendView(phone: "", onSelect: { _ in }, onClose: {})
}

