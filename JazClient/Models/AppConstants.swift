//
//  AppConstants.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import Foundation

struct AppConstants: Codable {
    let settings: [Settings]?
    let category: [Category]?
    let special: [Special]?
    let event: [Event]?
}

struct AppConstantItem: Codable {
    let id: String?
    let name: String?
    let max: String?
    let min: String?
    let value: String?
    let code: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, max, min, value, code
    }
}

struct AppConstantsResponse: Codable {
    let status: Bool?
    let code: Int?
    let message: String?
    let items: [AppConstantItem]?
}
