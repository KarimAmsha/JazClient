//
//  ChatInputBar.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
//            Button(action: {
//                // Voice input feature (optional)
//            }) {
//                Image(systemName: "mic")
//                    .font(.system(size: 20))
//            }

            TextField("اكتب رسالتك هنا", text: $text)
                .customFont(weight: .medium, size: 14)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)

            Button(action: {
                onSend()
            }) {
                Image(systemName: "location.fill")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.primary())
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
    }
}
