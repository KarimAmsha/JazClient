//
//  Slider.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

struct Slider: Codable, Hashable {
    let id: String?
    let title: String?
    let description: String?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case image
    }
}

