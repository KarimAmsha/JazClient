//
//  DateFormattable+Extension.swift
//  Khawi
//
//  Created by Karim Amsha on 13.11.2023.
//

import SwiftUI

protocol DateFormattable {
    var dateTime: String? { get }
    var formattedDate: String? { get }
}

extension DateFormattable {
    var formattedDate: String? {
        guard let dateString = dateTime else {
            return nil
        }
        return formatDateToString(createDateFromString(dateString, format: "yyyy-MM-dd") ?? Date(), format: "yyyy-MM-dd")
    }

    // Convert date string to Date with specific format
    private func createDateFromString(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }

    // Convert Date to date string with specific format
    private func formatDateToString(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

