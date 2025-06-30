//
//  ChatBubble.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct ChatBubble: View {
    let text: String
    let isSender: Bool
    let receiverImageURL: URL?

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isSender {
                Spacer(minLength: 40)
                Text(text)
                    .padding(12)
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .shadow(color: .brown.opacity(0.20), radius: 2, x: 0, y: 1)
            } else {
                Text(text)
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.black)
                    .cornerRadius(18)
                    .shadow(color: .gray.opacity(0.20), radius: 2, x: 0, y: 1)
                if let url = receiverImageURL {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: isSender ? .trailing : .leading)
        .padding(isSender ? .leading : .trailing, 70)
        .padding(.vertical, 2)
    }
}
