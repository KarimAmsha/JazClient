//
//  Complain.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import Foundation

struct Complain: Identifiable, Codable, Hashable  {
    let id: String?
    let fullName: String?
    let email: String?
    let phoneNumber: String?
    let details: String?
    let dtDate: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "full_name"
        case email
        case phoneNumber = "phone_number"
        case details = "details"
        case dtDate = "dt_date"
    }
}
