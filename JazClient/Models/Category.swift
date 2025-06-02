//
//  Category.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

// Define the ProductType enum
enum CategoryType: String, Codable {
    case wishes
    case events
    case userProducts
    case eventPreparation
    case giftVIP
    case unknown

    // If you want to add a custom initializer for more complex mappings
    init(from id: String) {
        switch id {
        case "65e4b5233f0719ac20b56738":
            self = .wishes
        case "6649ba2f7f7ad0728c62ab36":
            self = .events
        case "6649ba3d7f7ad0728c62ab3b":
            self = .userProducts
        case "6649ba587f7ad0728c62ab40":
            self = .eventPreparation
        case "6649ba6a7f7ad0728c62ab47":
            self = .giftVIP
        default:
            self = .unknown
        }
    }
}

struct Category: Codable, Hashable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let image: String?
    let isSoon: Bool?
    let sub: [SubCategory]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case image
        case isSoon
        case sub
    }

    var localizedName: String {
        return title ?? ""
    }

    var localizedDescription: String {
        return description ?? ""
    }
}

struct SubCategory: Codable, Hashable, Identifiable {
    let id: String
    let price: Double?
    let title: String?
    let description: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case price
        case title
        case description
        case image
    }
}
