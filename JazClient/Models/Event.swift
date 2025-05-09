//
//  Event.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

struct Event: Codable, Hashable {
    let id: String?
    let arName: String?
    let enName: String?
    let isDeleted: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case arName
        case enName
        case isDeleted
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
}


