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

struct OrderBody: Codable {
    var couponCode: String?
    var dt_date: String?
    var dt_time: String?
    var title: String?
    var address: String?
    var streetName: String?
    var buildingNo: String?
    var floorNo: String?
    var flatNo: String?
    var notes: String?
    var category_id: String?
    var sub_category_id: String?
    var paymentType: String?
    var payment_id: String?
    var lat: Double?
    var lng: Double?
    var id: String?
    var status: String?
    var canceled_note: String?
    var update_code: String?
    var rate_from_user: String?
    var note_from_user: String?
    var coupon: String?
    var extra: String?     // إذا أردته Array: [Category]? (حسب الداتا من السيرفر)
    // الحقول الجديدة من Order:
    var price: Double?
    var netTotal: Double?
    var total: Double?
    var totalDiscount: Double?
    var newTotal: Double?
    var newTax: Double?
    var orderNo: String?
    var createAt: String?
    var user: User?
    var employee: User?
    var provider: User?
    // يمكنك هنا دعم category/subCategory كـ موديلات مباشرة:
    var subCategory: Category?
    var category: Category?
}
