//
//  AddVIP.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct AddVIP: Codable, Hashable {
    let id: String?
    let images: [String]?
    let user_id: String?
    let event_id: String?
    let gender: String?
    let lat: Double?
    let lng: Double?
    let address: String?
    let date: String?
    let time: String?
    let note: String?
    let reciver_phone: String?
    let extra_note: String?
    let total: Int?
    let isNeedOffer: Bool?
    let offer: Int?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case images
        case user_id
        case event_id
        case gender
        case lat
        case lng
        case address
        case date
        case time
        case note
        case reciver_phone
        case extra_note
        case total
        case isNeedOffer
        case offer
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
