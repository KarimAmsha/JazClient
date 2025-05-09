//
//  NotificationItem.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct NotificationItem: Identifiable, Codable, Hashable {
    let id: String?
    let fromId: String?
    let userId: String?
    let title: String?
    let message: String?
    let dateTime: String?
    let type: String?
    let bodyParams: String?
    let isRead: Bool?
    let fromName: String?
    let toName: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fromId
        case userId = "user_id"
        case title
        case message = "msg"
        case dateTime = "dt_date"
        case type
        case bodyParams = "body_parms"
        case isRead
        case fromName
        case toName
    }
    
    // Add a computed property to map status to OrderType
    var notificationType: NotificationType? {
        return NotificationType(rawValue: type ?? "")
    }

    var formattedDate: String? {
        guard let dateTime = dateTime else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dateTime, outputFormat: "yyyy-MM-dd")
    }
}

