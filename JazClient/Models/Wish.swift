//
//  Wish.swift
//  Wishy
//
//  Created by Karim Amsha on 13.06.2024.
//

import SwiftUI

struct Wish: Codable, Hashable {
    let isComplete: Bool?
    let id: String?
    let product_id: Products?
    let group_id: WishGroup?
    let isShare: Bool?
    let type: String?
    let total: Double?
    let all_pays: Double?
    let user_id: User?
    let pays: [Pay]?
    let createAt: String?
    let finishAt: String?
    
    enum CodingKeys: String, CodingKey {
        case isComplete
        case id = "_id"
        case product_id
        case group_id
        case isShare
        case type
        case total
        case all_pays
        case user_id
        case pays
        case createAt
        case finishAt
    }

    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}

struct Pay: Codable, Hashable {
    let id: String?
    let total: Double?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case total
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}

struct AddWish: Codable, Hashable {
    let isComplete: Bool?
    let id: String?
    let product_id: String?
    let isShare: Bool?
    let type: String?
    let total: Int?
    let all_pays: Int?
    let user_id: String?
    let pays: [Pay]?
    let createAt: String?
    let finishAt: String?
    
    enum CodingKeys: String, CodingKey {
        case isComplete
        case id = "_id"
        case product_id
        case isShare
        case type
        case total
        case all_pays
        case user_id
        case pays
        case createAt
        case finishAt
    }

    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
