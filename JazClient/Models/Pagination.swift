//
//  Pagination.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation

struct Pagination: Codable {
    let size: Int?
    let totalElements: Int?
    let totalPages: Int?
    let pageNumber: Int?
}
