//
//  AddUserProduct.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct AddUserProduct: Codable, Hashable {
    let id: String?
    let images: [String]?
    let user_id: String?
    let title: String?
    let note: String?
    let total: Int?
    let name: String?
    let iban: String?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case images
        case user_id
        case title
        case note
        case total
        case name
        case iban
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
