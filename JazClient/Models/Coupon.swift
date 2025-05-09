//
//  Coupon.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import Foundation

struct Coupon: Codable  {
    let final_total: Double?
    let total_before_tax: Double?
    let discount: Double?
    let total_tax: Double?
}

struct CouponPrices: Codable  {
    let final_total: Double?
    let total_before_tax: Double?
    let discount: Int?
    let total_tax: Double?
}
