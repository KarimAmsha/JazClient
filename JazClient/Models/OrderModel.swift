//
//  Order.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import Foundation

// MARK: - OrderResponse
struct OrderResponse: Codable {
    let items: [OrderModel]?
    let statusCode: Int?
    let message: String?
    let messageAr: String?
    let messageEn: String?
    let pagination: Pagination?
    
    enum CodingKeys: String, CodingKey {
        case items
        case statusCode = "status_code"
        case message
        case messageAr = "messageAr"
        case messageEn = "messageEn"
        case pagination = "pagenation"
    }
}

// MARK: - OrderItem
struct OrderItem: Codable {
    // Add properties for OrderItem when available
    let product: Products?
}

struct AddressBook: Codable, Identifiable {
    var id: String?
    var streetName: String?
    var floorNo: String?
    var buildingNo: String?
    var flatNo: String?
    var type: AddressType?
    var createAt: String?
    var title: String?
    var lat: Double?
    var lng: Double?
    var address: String?
    var userId: String?
    var discount: Double?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case streetName = "streetName"
        case floorNo = "floorNo"
        case buildingNo = "buildingNo"
        case flatNo = "flatNo"
        case type = "type"
        case createAt = "createAt"
        case title = "title"
        case lat = "lat"
        case lng = "lng"
        case address = "address"
        case userId = "user_id"
        case discount = "discount"
    }
}

enum AddressType: String, Codable {
    case home
    case work
    case other
}

struct AddOrderResponse: Codable {
    let status: Bool
    let code: Int
    let message: String
    let items: AddOrderItem?
}

struct AddOrderItem: Codable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}

/////
///
///
///

struct OrderModel: Codable, Identifiable {
    var id: String? { _id }
    let _id: String?
    let loc: LocationPoint?
    let new_total: Double?
    let new_tax: Double?
    let update_code: String?
    let provider_total: Double?
    let admin_total: Double?
    let lat: Double?
    let lng: Double?
    let price: Double?
    let address: OrderAddress?
    let order_no: String?
    let tax: Double?
    let total: Double?
    let totalDiscount: Double?
    let netTotal: Double?
    var status: String?
    let createAt: String?
    let period: Int?
    let dt_date: String?
    let dt_time: String?
    let couponCode: String?
    let paymentType: String?
    let user: User?
    let notes: String?
    let canceled_note: String?
    let employee: Employee?
    let provider: Provider?
    let supervisor: Supervisor?
    let place: String?
    let sub_category_id: SubCategory?
    let category_id: Category?
    let extra: [SubCategory]?
    
    var formattedCreateDate: String? {
        guard let dtDate = dt_date else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var orderStatus: OrderStatus? {
        return OrderStatus(rawValue: status ?? "")
    }
}

struct LocationPoint: Codable {
    let type: String?
    let coordinates: [Double]?
}

struct OrderAddress: Codable {
    let address: String?
    let title: String?
    let streetName: String?
    let floorNo: String?
    let buildingNo: String?
    let flatNo: String?
    let type: String?
    let createAt: String?
    let isHidden: Bool?
    let _id: String?
    let lat: Double?
    let lng: Double?
    let user_id: String?
    let discount: Double?
}

struct Employee: Codable {
    // إذا لاحقًا جالك بيانات موظف ضيف خصائصه هنا
}

struct Provider: Codable {
    let token: String?
    let isDeleted: Bool?
    let cities: [String]?
    let _id: String?
    let image: String?
    let email: String?
    let phone_number: String?
    let password: String?
    let name: String?
    let isBlock: Bool?
    let orderPercentage: Double?
    let rate: Double?
    let details: String?
    let target: Double?
    let createAt: String?
    let __v: Int?
}

struct Supervisor: Codable {
    // إذا جالك داتا مش فاضية، ضيف خصائصها هنا
}

