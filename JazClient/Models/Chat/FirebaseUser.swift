//
//  FirebaseUser.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation

struct FirebaseUser: Codable, Identifiable {
    var id: String?
    var fcmToken: String?
    var image: String?
    var lastOnline: Int?
    var name: String?
    var online: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case fcmToken
        case image
        case lastOnline
        case name
        case online
    }

    // MARK: - Computed properties for SwiftUI display
    var displayName: String {
        name ?? "مستخدم غير معروف"
    }

    var profileImageURL: URL? {
        if let image = image {
            return URL(string: image)
        }
        return nil
    }

    var isOnline: Bool {
        online ?? false
    }
}
