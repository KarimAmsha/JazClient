//
//  HomeItems.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import SwiftUI

struct HomeItems: Codable, Hashable {
    let category: [Category]?
    let slider: [Slider]?
    let whatsApp: WhatsApp?
}
