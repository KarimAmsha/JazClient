//
//  CartItems.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct CartItems: Codable, Hashable {
    let results: [CartProduct]?
    let tax: Double?
    let deliveryCost: Double?
    let totalPrice: Double?
    let totalDiscount: Double?
    let finalTotal: Double?

    enum CodingKeys: String, CodingKey {
        case results
        case tax
        case deliveryCost = "deliveryCost"
        case totalPrice = "total_price"
        case totalDiscount = "total_discount"
        case finalTotal = "final_total"
    }
}

struct CartProduct: Codable, Hashable {
    let id: String?
    let rate: Double?
    let sale_price: Double?
    let image: String?
    let createdAt: String?
    let categoryId: String?
    let specialId: String?
    let isOffer: Bool?
    let isDeleted: Bool?
    let by: String?
    let favoriteId: String?
    let name: String?
    let description: String?
    let cartId: String?
    let qty: Int?
    let total: Double?
    let totalDiscount: Double?

    // ✅ أضف هذين السطرين
    let variation_name: String?
    let variation_sku: String?

    var formattedCreateDate: String? {
        guard let createat = createdAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: createat, outputFormat: "yyyy-MM-dd")
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rate
        case sale_price
        case image
        case createdAt = "createat"
        case categoryId = "category_id"
        case specialId = "special_id"
        case isOffer
        case isDeleted
        case by
        case favoriteId = "favorite_id"
        case name
        case description
        case cartId = "cart_id"
        case qty
        case total = "Total"
        case totalDiscount = "TotalDiscount"
        case variation_name
        case variation_sku
    }
}
