//
//  TamaraProduct.swift
//  Wishy
//
//  Created by Karim OTHMAN on 29.04.2025.
//

import SwiftUI

// MARK: - Tamara Product Model
struct TamaraProduct: Codable, Hashable {
    let product_id: String
    let variation_name: String
    let variation_sku: String
    let qty: Int
}

// MARK: - Tamara Body
struct TamaraBody: Codable, Hashable {
    let amount: Double
    let products: [TamaraProduct]
}
