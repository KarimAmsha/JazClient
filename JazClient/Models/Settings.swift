//
//  Settings.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

struct Settings: Codable, Hashable {
    let id: String?
    let name: String?
    let max: String?
    let min: String?
    let value: String?
    let code: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case max
        case min
        case value
        case code
    }
}

