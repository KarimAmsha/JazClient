//
//  OrderRealTime.swift
//  JazClient
//
//  Created by Karim OTHMAN on 1.07.2025.
//

import Foundation

struct OrderRealTime: Codable, Identifiable {
    var id: String { order_id ?? "" }
    var employee_id: String?
    var order_id: String?
    var order_no: String?
    var status: String?
    var user_id: String?
    var timestamp: Int64?
}
