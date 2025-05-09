//
//  OrderDetails.swift
//  Wishy
//
//  Created by Karim Amsha on 29.05.2024.
//

// MARK: - OrderDetails Model
struct OrderDetails: Codable, Identifiable {
    var id: String?
    let orderNo: String?
    let tax: Double?
    let deliveryCost: Double?
    let netTotal: Double?
    let total: Double?
    let totalDiscount: Double?
    let adminTotal: Double?
    let providerTotal: Double?
    let status: String?
    let dtDate: String?
    let dtTime: String?
    let lat: Double?
    let lng: Double?
    let paymentType: String?
    let couponCode: String?
    let userId: User?
    let createAt: String?
    let items: [OrderProducts]?
    let address: String?
    let orderType: Int?
    let isAddressBook: Bool?
    let addressBook: AddressBook?
    
    var formattedCreateDate: String? {
        guard let dtDate = dtDate else { return nil }
        return Utilities.convertDateStringToDate(stringDate: dtDate, outputFormat: "yyyy-MM-dd")
    }
    
    var orderStatus: OrderStatus? {
        return OrderStatus(rawValue: status ?? "")
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id", orderNo = "Order_no", tax = "Tax", deliveryCost = "DeliveryCost", netTotal = "NetTotal", total = "Total", totalDiscount = "TotalDiscount", adminTotal = "Admin_Total", providerTotal = "provider_Total", status = "Status", dtDate = "dt_date", dtTime = "dt_time", lat, lng, paymentType = "PaymentType", couponCode, userId = "user_id", createAt, items, address, orderType = "OrderType", isAddressBook = "is_address_book", addressBook = "address_book"
    }
}

// MARK: - Order Response Model
struct OrderDetailsItem: Codable {
    let items: OrderDetails?
    let tax: Double?
    let deliveryCost: Double?
    let totalPrice: Double?
    let totalDiscount: Double?
    let finalTotal: Double?
    let isRate: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case items, tax, deliveryCost, totalPrice = "total_price", totalDiscount = "total_discount", finalTotal = "final_total", isRate
    }
}

