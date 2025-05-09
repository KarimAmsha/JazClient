//
//  Mark.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import Foundation
import MapKit

struct Mark: Identifiable, Hashable {
    let id = UUID()
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var show: Bool = false
    var imageName: String?
    var isUserLocation: Bool = false
}

