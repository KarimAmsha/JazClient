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

// MARK: - Order
struct OrderModel: Codable, Identifiable {
    let id: String?
    let orderType: Int?
    let orderNo: String?
    let total: Double?
    let status: String?
    let dtDate: String?
    let dtTime: String?
    let address: String?
    let addressBook: AddressBook?
    let supplierId: Supplier?
    let items: [OrderProducts]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orderType = "OrderType"
        case orderNo = "Order_no"
        case total = "Total"
        case status = "Status"
        case dtDate = "dt_date"
        case dtTime = "dt_time"
        case address = "address"
        case addressBook = "address_book"
        case supplierId = "Supplier_id"
        case items
    }
    
    var formattedCreateDate: String? {
        guard let dtDate = dtDate else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var orderStatus: OrderStatus? {
        return OrderStatus(rawValue: status ?? "")
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
