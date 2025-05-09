//
//  AddressItem.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import Foundation

struct AddressItem: Codable, Hashable, Identifiable {
    let streetName: String?
    let floorNo: String?
    let buildingNo: String?
    let flatNo: String?
    let type: String?
    let createAt: String?
    let id: String?
    let title: String?
    let lat: Double?
    let lng: Double?
    let address: String?
    let userId: String?
    let discount: Int?

    enum CodingKeys: String, CodingKey {
        case streetName, floorNo, buildingNo, flatNo, type, createAt
        case id = "_id"
        case userId = "user_id"
        case title, lat, lng, address, discount
    }
    
    // Add a computed property to map status to OrderType
    var addressType: PlaceType? {
        return PlaceType(rawValue: type ?? "")
    }
}

