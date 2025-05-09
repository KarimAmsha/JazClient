//
//  Supplier.swift
//  Wishy
//
//  Created by Karim Amsha on 28.05.2024.
//

import SwiftUI

struct Supplier: Codable, Hashable {
    let id: String?
    let token: String?
    let isDeleted: Bool?
    let cities: [String]?
    let image: String?
    let email: String?
    let password: String?
    let name: String?
    let isBlock: Bool?
    let orderPercentage: Int?
    let rate: Double?
    let details: String?
    let __v: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case token
        case isDeleted
        case cities
        case image
        case email
        case password
        case name
        case isBlock
        case orderPercentage
        case rate
        case details
        case __v
    }
}
