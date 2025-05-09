//
//  CartTotal.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import Foundation

struct CartTotal: Codable {
    let tax: Double?
    let deliveryCost: Double?
    let expressCost: Double?
    let total_price: Double?
    let total_discount: Double?
    let final_total: Double?
}
