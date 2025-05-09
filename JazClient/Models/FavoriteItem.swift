//
//  FavoriteItem.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct FavoriteItem: Codable {
    let id: String?
    let userId: String?
    let productId: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case productId = "product_id"
        case createdAt = "createAt"
    }
}

struct FavoriteItems: Codable {
    let id: String?
    let userId: String?
    let productId: Products?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case productId = "product_id"
        case createdAt = "createAt"
    }
}
