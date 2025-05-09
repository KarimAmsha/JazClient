//
//  Cart.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI

struct Cart: Codable, Hashable {
    let id: String?
    let user_id: String?
    let product_id: String?
    let qty: Int?
    let Total: Double?
    let TotalDiscount: Double?
    let createAt: String?

    var formattedCreateDate: String? {
        guard let createat = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: createat, outputFormat: "yyyy-MM-dd")
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id
        case product_id
        case qty
        case Total
        case TotalDiscount
        case createAt
    }
}

