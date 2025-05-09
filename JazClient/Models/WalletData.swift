//
//  WalletData.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import Foundation

struct WalletData: Identifiable, Codable, Hashable  {
    let id: String?
    let orderNo: String?
    let user: String?
    let details: String?
    let total: Double?
    let type: TransactionType?
    let paymentType: String?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orderNo = "order_no"
        case user
        case details
        case total
        case type
        case paymentType
        case createAt
    }
    
    var formattedDate: String? {
        guard let dateString = createAt else {
            return nil
        }
        return formatDateToString(createDateFromString(dateString, format: "yyyy-MM-dd") ?? Date(), format: "yyyy-MM-dd")
    }

    // Convert Date to date string with specific format
    private func formatDateToString(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    // Convert date string to Date with specific format
    private func createDateFromString(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
}
