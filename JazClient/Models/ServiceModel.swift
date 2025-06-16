//
//  ServiceModel.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 7.05.2025.
//

import SwiftUI

struct ServiceModel {
    var title: String = ""
    var description: String = ""
    var images: [UIImage] = []
    var price: Double = 0
    var revisionCount: Int = 0
    var revisionPrice: Double = 0
    var deliveryTime: Int = 1
}

struct ServiceItem: Codable, Identifiable {
    let id: String           // خدمة ID
    let title: String?
    let description: String?
    let price: Double
    let image: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case price
        case image
        case type
    }
}

struct SelectedServiceItem: Codable, Identifiable, Equatable, Hashable {
    var id = UUID().uuidString

    let service: SubCategory
    let quantity: Int
    let categoryId: String
    let subCategoryId: String
    let categoryTitle: String
    let subCategoryTitle: String

    // استخراج القيم للجيسون المطلوب
    func toJson() -> [String: Any] {
        return [
            "category_id": categoryId,
            "sub_category_id": subCategoryId,
            "title": categoryTitle,
            "streetName": subCategoryTitle,
            "service_id": service.id,
            "qty": quantity
        ]
    }
}
