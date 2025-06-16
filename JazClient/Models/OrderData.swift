//
//  OrderData.swift
//  JazClient
//
//  Created by Karim OTHMAN on 16.06.2025.
//


import CoreLocation

struct OrderData: Codable, Equatable, Hashable {
    let services: [SelectedServiceItem]
    let address: AddressItem?
    let userLocation: Location? // location إذا ما في عنوان محفوظ
    let notes: String?
    let date: String?       // مثال: "2023-01-01"
    let time: String?       // مثال: "10:00"

    func toJson(couponCode: String? = nil, paymentType: String? = nil) -> [String: Any] {
        var service = services.first!
        var dict: [String: Any] = [
            "category_id": service.categoryId,
            "sub_category_id": service.subCategoryId,
            "title": service.categoryTitle,
            "streetName": service.subCategoryTitle,
            "notes": notes ?? "",
            "dt_date": date ?? "",
            "dt_time": time ?? "",
            "qty": service.quantity,
        ]
        if let address = address {
            dict["address_id"] = address.id
            dict["address"] = address.address
            dict["lat"] = address.lat
            dict["lng"] = address.lng
        } else if let loc = userLocation {
            dict["lat"] = loc.lat
            dict["lng"] = loc.lng
        }
        if let coupon = couponCode, !coupon.isEmpty {
            dict["couponCode"] = coupon
        }
        if let payType = paymentType {
            dict["paymentType"] = payType
        }
        return dict
    }
}

struct Location: Codable, Equatable, Hashable {
    let lat: Double
    let lng: Double

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lng)
    }
}
