//
//  FirebaseChat.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation

struct FirebaseChat: Codable, Identifiable {
    var id: String?  // = chatId
    var chatEnabled: Bool?
    var lastMessage: String?
    var lastMessageDate: Int?
    var orderId: String?
    var senderId: String?
    var receiverId: String?
    var messagesList: [FirebaseMessage]?

    enum CodingKeys: String, CodingKey {
        case id
        case chatEnabled
        case lastMessage
        case lastMessageDate
        case orderId
        case senderId
        case receiverId
        case messagesList
    }
}

