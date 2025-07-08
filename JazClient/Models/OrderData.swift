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

    func toJson(couponCode: String? = nil, paymentType: Int? = nil) -> [String: Any] {
        let service = services.first!
        var dict: [String: Any] = [
            "category_id": service.categoryId,
            "sub_category_id": service.subCategoryId,
            "title": service.categoryTitle,
            "streetName": "",
            "notes": notes ?? "",
            "dt_date": date ?? "",
            "dt_time": time ?? "",
            // الكمية لو تحتاجها أضفها هنا:
            // "qty": service.quantity,
        ]

        // الموقع الجغرافي دائمًا لازم يكون lat/lng، من العنوان أو من userLocation
        if let address = address {
            dict["lat"] = address.lat
            dict["lng"] = address.lng
        } else if let loc = userLocation {
            dict["lat"] = loc.lat
            dict["lng"] = loc.lng
        } else {
            dict["lat"] = Constants.defaultLat // أو قيمة افتراضية لو تحب
            dict["lng"] = Constants.defaultLng
        }

        // الكوبون دائمًا حتى لو فاضي
        dict["couponCode"] = couponCode ?? ""

        // نوع الدفع دائمًا لازم يكون Int
        dict["paymentType"] = paymentType ?? 1 // أو القيمة الافتراضية المناسبة لك

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
