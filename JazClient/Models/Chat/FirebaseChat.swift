//
//  FirebaseChat.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation

struct FirebaseChat: Codable, Identifiable {
    var id: String?
    var chatEnabled: Bool?
    var lastMessage: String?
    var lastMessageDate: Int64?
    var orderId: String?
    var senderId: String?
    var receiverId: String?
    var messagesList: [FirebaseMessage]?
    var onChat: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case chatEnabled
        case lastMessage
        case lastMessageDate
        case orderId
        case senderId
        case receiverId
        case messagesList
        case onChat
    }
}

extension FirebaseChat: Equatable {
    static func == (lhs: FirebaseChat, rhs: FirebaseChat) -> Bool {
        lhs.id == rhs.id &&
        lhs.senderId == rhs.senderId &&
        lhs.receiverId == rhs.receiverId
    }
}
