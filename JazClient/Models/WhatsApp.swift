//
//  WhatsApp.swift
//  Wishy
//
//  Created by Karim Amsha on 21.07.2024.
//

import SwiftUI

struct WhatsApp: Codable, Hashable {
    let id: String?
    let data: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case data = "Data"
    }
}
