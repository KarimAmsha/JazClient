//
//  ConstantItem.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation

struct ConstantItem: Codable, Hashable, Equatable {
    let _id: String?
    let `Type`: String?
    let Title: String?
    let Content: String?
    
    var constantType: ConstantType? {
        return ConstantType(rawValue: `Type` ?? "")
    }
}

