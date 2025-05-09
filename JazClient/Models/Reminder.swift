//
//  Reminder.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct Reminder: Codable, Hashable {
    let id: String?
    let title: String?
    let date: String?
    let user_id: User?
    let before: Int?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case date
        case user_id
        case before
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var formattedDate: String? {
        guard let dtDate = date else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}

struct CreateReminder: Codable, Hashable {
    let id: String?
    let title: String?
    let date: String?
    let user_id: String?
    let before: Int?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case date
        case user_id
        case before
        case createAt
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = createAt else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var formattedDate: String? {
        guard let dtDate = date else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
}
