//
//  FirebaseMessage.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation

struct FirebaseMessage: Codable, Identifiable {
    var id: String?
    var message: String?
    var messageDate: Int64?
    var senderId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case messageDate
        case senderId
    }
}
