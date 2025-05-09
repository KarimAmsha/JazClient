//
//  WhatsApp.swift
//  Wishy
//
//  Created by Karim Amsha on 21.07.2024.
//

import SwiftUI

struct WhatsApp: Codable, Hashable {
    let _id: String?
    let arTitle: String?
    let enTitle: String?
    let arDescription: String?
    let enDescription: String?
    let product_id: String?
    let store_id: String?
    let url: String?
    let expiry_date: String?
    let ads_for: Int?
    let image: String?
    let is_ads_redirect_to_store: Bool?
    let is_ads_have_expiry_date: Bool?
    let isApprove: Bool?
    let isActive: Bool?
}
