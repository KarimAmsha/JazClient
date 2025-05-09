//
//  APIResponse.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation

struct APIResponseCodable: Codable {
    let status: Bool
    let code: Int
    let message: String
}

struct ArrayAPIResponse<T: Codable>: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: [T]?
    let pagination: Pagination?
}

struct PaginationArrayAPIResponse<T: Codable>: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: [T]?
    let pagination: Pagination?
}

struct SingleAPIResponse<T: Codable>: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: T?
}

struct BaseCustomStatusAPIResponse<T: Codable>: Codable {
    let status_code: Int
    let status: Bool
    let message: String
    let items: T?
}

struct CustomSingleAPIResponse<T: Codable>: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: [T]?

    enum CodingKeys: String, CodingKey {
        case status
        case code
        case message
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try container.decode(Bool.self, forKey: .status)
        code = try container.decode(Int.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)

        // Decode items as an array of dictionaries
        if let itemsArray = try? container.decodeIfPresent([T].self, forKey: .items) {
            items = itemsArray
        } else {
            items = nil
        }
    }
}

//struct OrdersApiResponse: Codable {
//    let items: [Order]?
//    let statusCode: Int?
//    let error: String?
//    let status_code: Int?
//    let message: String?
//    let messageAr: String?
//    let messageEn: String?
//    let pagenation: Pagination?
//}
//
//struct AppConstantsApiResponse: Codable {
//    let status_code: Int?
//    let status: Bool?
//    let message: String?
//    let items: AppConstants?
//}
//
//struct WalletResponse: Codable {
//    var items: [WalletData]?
//    let total: Int?
//    let last_date: CustomDate?
//    let status_code: Int?
//    let message: String?
//    let messageAr: String?
//    let messageEn: String?
//    let pagenation: Pagination?
//}

// Custom type to handle both string and integer representations of date
enum CustomDate: Codable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(CustomDate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode String or Int, but found neither."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .int(let intValue):
            try container.encode(intValue)
        }
    }
    
    func formattedDateString(with format: String) -> String? {
        switch self {
        case .string(let stringValue):
            // Assuming stringValue is a valid date string
            return formatDateToString(createDateFromString(stringValue, format: format) ?? Date(), format: format)
        case .int(let intValue):
            // Assuming intValue is a Unix timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(intValue))
            return formatDateToString(date, format: format)
        }
    }

    private func formatDateToString(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    private func createDateFromString(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
}

//struct PointApiResponse: Codable {
//    let status_code: Int?
//    let status: Bool?
//    let message: String?
//    let items: CheckPoint?
//}

struct WalletResponse: Codable {
    var items: [WalletData]?
    let total: Double?
    let last_date: CustomDate?
    let status_code: Int?
    let message: String?
    let messageAr: String?
    let messageEn: String?
    let pagenation: Pagination?
}

struct CustomApiResponse: Codable {
    let status_code: Int?
    let status: Bool?
    let messageAr: String?
    let messageEn: String?
    let items: String?
}

struct TamaraCheckoutResponse: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: TamaraCheckoutData?
}

struct TamaraCheckoutData: Codable {
    let checkout_url: String?
}
