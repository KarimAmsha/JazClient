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

    var body: some View {
        HStack {
            if isSender { Spacer() }
            Text(text)
                .padding(12)
                .background(isSender ? Color.brown : Color.gray.opacity(0.15))
                .foregroundColor(isSender ? .white : .black)
                .cornerRadius(12)
            if !isSender { Spacer() }
        }
        .frame(maxWidth: .infinity, alignment: isSender ? .trailing : .leading)
    }
}
