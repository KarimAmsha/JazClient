//
//  CreateGroup.swift
//  Wishy
//
//  Created by Karim Amsha on 12.06.2024.
//

import SwiftUI

struct CreateGroup: Codable, Hashable {
    let id: String?
    let name: String?
    let type: String?
    let user_id: String?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case user_id
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
