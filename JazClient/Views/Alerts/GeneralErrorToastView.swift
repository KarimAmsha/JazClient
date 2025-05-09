//
//  GeneralErrorToastView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct GeneralErrorToastView: View {
    let title: String
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(.red)
                .cornerRadius(24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .customFont(weight: .bold, size: 16)
                Text(message)
                    .customFont(weight: .bold, size: 16)
                    .opacity(0.8)
            }
            
            Spacer()
        }
        .foregroundColor(.black)
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 42, trailing: 16))
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 40, x: 0, y: -4)
    }
}
