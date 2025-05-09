//
//  NotificationRowView.swift
//  Jaz Client
//
//  Created by Karim Amsha on 4.12.2023.
//

import SwiftUI

struct NotificationRowView: View {
    let notification: NotificationItem

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(notification.title ?? "")
                        .customFont(weight: .bold, size: 14)
                    
                    Spacer()
                    
                    Text(notification.formattedDate ?? "")
                        .customFont(weight: .bold, size: 10)
                }

                Text(notification.message ?? "")
                    .customFont(weight: .regular, size: 10)
            }
            .foregroundColor(.black222020())

            CustomDivider(color: .grayEFEFEF())
        }
        .padding()
    }
}

#Preview {
    NotificationRowView(notification: NotificationItem(id: nil, fromId: nil, userId: nil, title: nil, message: nil, dateTime: nil, type: nil, bodyParams: nil, isRead: nil, fromName: nil, toName: nil))
}
