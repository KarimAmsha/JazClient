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

struct OrderBody: Codable, Identifiable {
    var id: String? { _id ?? id_ }
    let _id: String?         // موجود بالجيسون كـ "_id"
    let id_: String?         // دعم لأي حالة id أخرى (لن يؤثر إذا كان دائمًا nil)
    
    let new_total: Double?
    let new_tax: Double?
    let extra: [SubCategory]?           // أو [SubCategory]? حسب الحاجة
    let update_code: String?
    let provider_total: Double?
    let admin_total: Double?
    let lat: Double?
    let lng: Double?
    let price: Double?
    let address: OrderAddress?    // إذا الجيسون يعيد object مش string (حسب الداتا)
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
    let sub_category_id: SubCategory?
    let category_id: Category?
    let couponCode: String?
    let paymentType: String?
    let user: User?
    let notes: String?
    let canceled_note: String?
    let employee: Employee?
    let provider: User?
    let supervisor: Supervisor?
    let place: String?
    let loc: LocationPoint?
    
    // --- من عندك إذا عندك حاجات custom:
    let payment_id: String?
    let title: String?
    let streetName: String?
    let buildingNo: String?
    let floorNo: String?
    let flatNo: String?
    let rate_from_user: String?
    let note_from_user: String?
    let coupon: String?
    // دعم الموديلات إذا احتجت:
    let subCategory: Category?
    let category: Category?
    
    // التوافق مع أسماء مختلفة للحقل "id"
    private enum CodingKeys: String, CodingKey {
        case _id
        case id_ = "id"
        case new_total, new_tax, extra, update_code, provider_total, admin_total, lat, lng, price, address,
             order_no, tax, total, totalDiscount, netTotal, status, createAt, period, dt_date, dt_time, sub_category_id,
             category_id, couponCode, paymentType, user, notes, canceled_note, employee, provider, supervisor, place, loc,
             payment_id, title, streetName, buildingNo, floorNo, flatNo, rate_from_user, note_from_user, coupon,
             subCategory, category
    }
}
