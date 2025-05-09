//
//  GeneralAlertToastView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

enum AlertType {
    case success, error, info
}

struct GeneralAlertToastView: View {
    let title: String
    let message: String
    var type: AlertType

    var iconName: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(iconColor)
                .cornerRadius(24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .customFont(weight: .bold, size: 16)
                Text(message)
                    .customFont(weight: .regular, size: 14)
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
