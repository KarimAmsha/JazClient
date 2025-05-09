//
//  WelcomeSlideView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct WelcomeSlideView: View {
    let item: WelcomeItem

    var body: some View {
        VStack {      
            AsyncImageView(
                width: UIScreen.main.bounds.width,
                height: 320,
                cornerRadius: 10,
                imageURL: item.icon?.toURL(),
                placeholder: Image(systemName: "photo"),
                contentMode: .fit
            )

            VStack(alignment: .center, spacing: 16) {
                Text(item.Title ?? "")
                    .customFont(weight: .bold, size: 20)
                    .foregroundColor(.primaryBlack())
                    .multilineTextAlignment(.leading)

                Text(item.Description ?? "")
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.primaryBlack())
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
    }
}

struct WelcomeSlideView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeSlideView(item: WelcomeItem(_id: "", icon: "", Title: LocalizedStringKey.welcomeTitle3, Description: LocalizedStringKey.welcomeDesc3))
    }
}

