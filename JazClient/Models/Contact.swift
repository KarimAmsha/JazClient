//
//  Contact.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import Foundation

struct Contact: Identifiable, Codable, Hashable  {
    let id: String?
    let Name: String?
    let Data: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case Name
        case Data
    }
}
