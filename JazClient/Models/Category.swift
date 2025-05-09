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

struct Category: Codable, Hashable {
    let id: String?
    let arName: String?
    let enName: String?
    let enDescription: String?
    let arDescription: String?
    let isDeleted: Bool?
    let type: String?
    let image: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case arName
        case enName
        case enDescription
        case arDescription
        case isDeleted
        case type
        case image
        case v = "__v"
    }
    
    var categoryType: CategoryType {
        guard let id = id else { return .unknown }
        return CategoryType(from: id)
    }

    // Computed property to return name based on app language
    var localizedName: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arName
        default:
            return enName
        }
    }
    
    var localizedDescription: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arDescription
        default:
            return enDescription
        }
    }
}


