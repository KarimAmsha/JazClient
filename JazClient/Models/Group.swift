//
//  Group.swift
//  Wishy
//
//  Created by Karim Amsha on 10.06.2024.
//

import SwiftUI

struct Group: Codable, Hashable {
    let id: String?
    let name: String?
    let type: String?
    let user_id: User?
    let isShare: Bool?
    let createAt: String?
    let items: [Products]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case user_id
        case isShare
        case createAt
        case items
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}

struct WishGroup: Codable, Hashable {
    let id: String?
    let name: String?
    let type: String?
    let user_id: String?
    let isShare: Bool?
    let createAt: String?
    let items: [Products]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case user_id
        case isShare
        case createAt
        case items
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
