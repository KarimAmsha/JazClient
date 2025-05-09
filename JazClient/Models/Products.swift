//
//  Products.swift
//  Wishy
//
//  Created by Karim Amsha on 20.05.2024.
//

import Foundation

struct Products: Codable, Hashable {
    let rate: Double?
    let isFromUser: Bool?
    let id: String?
    let sale_price: Double?
    let cost_price: Double?
    let image: String?
    let createat: String?
    let category_id: String?
    let special_id: String?
    let isOffer: Bool?
    let isDeleted: Bool?
    let favorite_id: String?
    let name: String?
    let description: String?
    let arName: String?
    let enName: String?
    let arDescription: String?
    let enDescription: String?
    let by: String?
    let qty: Int?
    let total: Double?
    let totalDiscount: Double?
    let type: String?
    let quantity: Int?
    let SKU: String?
    let attributes: [Attribute]?
    let variation_name: String?
    let variation_sku: String?

    // MARK: - Computed properties

    var isFavorite: Bool {
        return favorite_id != nil && !favorite_id!.isEmpty
    }

    var formattedCreateDate: String? {
        guard let createat = createat else { return nil }
        return Utilities.convertDateStringToDate(stringDate: createat, outputFormat: "yyyy-MM-dd")
    }

    var localizedName: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arName ?? name
        default:
            return enName ?? name
        }
    }

    var localizedDescription: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arDescription ?? description
        default:
            return enDescription ?? description
        }
    }

    // MARK: - Coding keys

    enum CodingKeys: String, CodingKey {
        case rate
        case isFromUser
        case id = "_id"
        case sale_price
        case cost_price
        case image
        case createat
        case category_id
        case special_id
        case isOffer
        case isDeleted
        case favorite_id
        case name
        case description
        case arName
        case enName
        case arDescription
        case enDescription
        case by
        case qty
        case total
        case totalDiscount
        case type
        case quantity
        case SKU
        case attributes
        case variation_name
        case variation_sku
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rate = try container.decodeIfPresent(Double.self, forKey: .rate)
        isFromUser = try container.decodeIfPresent(Bool.self, forKey: .isFromUser)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        sale_price = try container.decodeIfPresent(Double.self, forKey: .sale_price)
        cost_price = try container.decodeIfPresent(Double.self, forKey: .cost_price)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        createat = try container.decodeIfPresent(String.self, forKey: .createat)
        category_id = try container.decodeIfPresent(String.self, forKey: .category_id)
        special_id = try container.decodeIfPresent(String.self, forKey: .special_id)
        isOffer = try container.decodeIfPresent(Bool.self, forKey: .isOffer)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        favorite_id = try container.decodeIfPresent(String.self, forKey: .favorite_id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        arName = try container.decodeIfPresent(String.self, forKey: .arName)
        enName = try container.decodeIfPresent(String.self, forKey: .enName)
        arDescription = try container.decodeIfPresent(String.self, forKey: .arDescription)
        enDescription = try container.decodeIfPresent(String.self, forKey: .enDescription)
        by = try container.decodeIfPresent(String.self, forKey: .by)
        qty = try container.decodeIfPresent(Int.self, forKey: .qty)
        total = try container.decodeIfPresent(Double.self, forKey: .total) // ✅ مضاف حديثًا
        totalDiscount = try container.decodeIfPresent(Double.self, forKey: .totalDiscount) // ✅ مضاف حديثًا
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
        SKU = try container.decodeIfPresent(String.self, forKey: .SKU)
        attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
        
        let decodedType = try container.decodeIfPresent(String.self, forKey: .type)
        type = (decodedType?.isEmpty ?? true) ? "simple" : decodedType!
        variation_name = try container.decodeIfPresent(String.self, forKey: .variation_name)
        variation_sku = try container.decodeIfPresent(String.self, forKey: .variation_sku)
    }
}

struct OrderProducts: Codable, Hashable {
    let rate: Double?
    let id: String?
    let sale_price: Double?
    let cost_price: Double?
    let image: String?
    let createat: String?
    let category_id: String?
    let special_id: String?
    let isOffer: Bool?
    let isDeleted: Bool?
    let favorite_id: String?
    let name: String?
    let description: String?
    let arName: String?
    let enName: String?
    let arDescription: String?
    let enDescription: String?
    let by: String?
    let qty: Int?
    let type: String?
    let quantity: Int?
    let SKU: String?
    let attributes: [Attribute]?
    let variation_name: String?
    let variation_sku: String?

    // MARK: - Computed Properties

    var formattedCreateDate: String? {
        guard let createat = createat else { return nil }
        return Utilities.convertDateStringToDate(stringDate: createat, outputFormat: "yyyy-MM-dd")
    }

    var localizedName: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arName ?? name
        default:
            return enName ?? name
        }
    }

    var localizedDescription: String? {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ar":
            return arDescription ?? description
        default:
            return enDescription ?? description
        }
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case rate
        case id = "_id"
        case sale_price
        case cost_price
        case image
        case createat
        case category_id
        case special_id
        case isOffer
        case isDeleted
        case favorite_id
        case name
        case description
        case arName
        case enName
        case arDescription
        case enDescription
        case by
        case qty
        case type
        case quantity
        case SKU
        case attributes
        case variation_name
        case variation_sku
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rate = try container.decodeIfPresent(Double.self, forKey: .rate)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        sale_price = try container.decodeIfPresent(Double.self, forKey: .sale_price)
        cost_price = try container.decodeIfPresent(Double.self, forKey: .cost_price)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        createat = try container.decodeIfPresent(String.self, forKey: .createat)
        category_id = try container.decodeIfPresent(String.self, forKey: .category_id)
        special_id = try container.decodeIfPresent(String.self, forKey: .special_id)
        isOffer = try container.decodeIfPresent(Bool.self, forKey: .isOffer)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        favorite_id = try container.decodeIfPresent(String.self, forKey: .favorite_id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        arName = try container.decodeIfPresent(String.self, forKey: .arName)
        enName = try container.decodeIfPresent(String.self, forKey: .enName)
        arDescription = try container.decodeIfPresent(String.self, forKey: .arDescription)
        enDescription = try container.decodeIfPresent(String.self, forKey: .enDescription)
        by = try container.decodeIfPresent(String.self, forKey: .by)
        qty = try container.decodeIfPresent(Int.self, forKey: .qty)
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
        SKU = try container.decodeIfPresent(String.self, forKey: .SKU)
        attributes = try container.decodeIfPresent([Attribute].self, forKey: .attributes)
        
        if let decodedType = try container.decodeIfPresent(String.self, forKey: .type), !decodedType.isEmpty {
            type = decodedType
        } else {
            type = "simple"
        }
        variation_name = try container.decodeIfPresent(String.self, forKey: .variation_name)
        variation_sku = try container.decodeIfPresent(String.self, forKey: .variation_sku)
    }
}

//struct By: Codable, Hashable {
//    let token: String?
//    let isDeleted: Bool?
//    let cities: [String]?
//    let id: String?
//    let image: String?
//    let email: String?
//    let password: String?
//    let name: String?
//    let isBlock: Bool?
//    let orderPercentage: Int?
//    let rate: Double?
//    let details: String?
//    let v: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case token, isDeleted, cities
//        case id = "_id"
//        case image, email, password, name, isBlock, orderPercentage, rate, details
//        case v = "__v"
//    }
//}

//struct OrderProducts: Codable, Hashable {
//    let rate: Double?
//    let id: String?
//    let sale_price: Double?
//    let image: String?
//    let createat: String?
//    let category_id: String?
//    let special_id: String?
//    let isOffer: Bool?
//    let isDeleted: Bool?
//    let favorite_id: String?
//    let name: String?
//    let description: String?
//    let arName: String?
//    let enName: String?
//    let arDescription: String?
//    let enDescription: String?
//    let by: String?
//    let qty: Int?
//    let attributes: [Attribute]?
//    let type: String?
//
//    var formattedCreateDate: String? {
//        guard let createat = createat else { return nil }
//        return Utilities.convertDateStringToDate(stringDate: createat, outputFormat: "yyyy-MM-dd")
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case rate
//        case id = "_id"
//        case sale_price
//        case image
//        case createat
//        case category_id
//        case special_id
//        case isOffer
//        case isDeleted
//        case favorite_id
//        case name
//        case description
//        case arName
//        case enName
//        case arDescription
//        case enDescription
//        case by
//        case qty
//        case attributes
//        case type
//    }
//    
//    // Computed property to return name based on app language
//    var localizedName: String? {
//        let languageCode = Locale.current.language.languageCode?.identifier
//        switch languageCode {
//        case "ar":
//            return arName
//        default:
//            return enName
//        }
//    }
//    
//    var localizedDescription: String? {
//        let languageCode = Locale.current.language.languageCode?.identifier
//        switch languageCode {
//        case "ar":
//            return arDescription
//        default:
//            return enDescription
//        }
//    }
//}

enum StringOrInt: Codable, Hashable {
    case string(String)
    case int(Int)

    var value: String {
        switch self {
        case .string(let s): return s
        case .int(let i): return "\(i)"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
        } else {
            throw DecodingError.typeMismatch(StringOrInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Int"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let i): try container.encode(i)
        case .string(let s): try container.encode(s)
        }
    }
}

struct Attribute: Codable, Hashable {
    let id: String?
    let visible: Bool?
    let variation: Bool?
    let options: [AttributeOption]?
}

struct AttributeOption: Codable, Hashable {
    let name: String?
    let sku: String?
}
