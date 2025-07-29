//
//  Company.swift
//  JazClient
//
//  Created by Karim OTHMAN on 29.07.2025.
//

import Foundation

struct Company: Codable { // Codable = Decodable + Encodable
    let id: String
    let companyName: String
    let email: String
    let phoneNumber: String
    let address: String
    let lat: Double
    let lng: Double
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case companyName = "company_name"
        case email
        case phoneNumber = "phone_number"
        case address
        case lat
        case lng
        case createdAt = "createAt"
    }
}
