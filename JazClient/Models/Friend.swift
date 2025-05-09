//
//  Friend.swift
//  Wishy
//
//  Created by Karim Amsha on 12.06.2024.
//

import SwiftUI

struct Friend: Codable, Hashable {
    let id: String?
    let user_id: User?
    let friend_id: User?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id
        case friend_id
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
