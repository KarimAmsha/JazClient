//
//  CustomMapAnnotation.swift
//  Khawi
//
//  Created by Karim Amsha on 9.11.2023.
//

import MapKit
import SwiftUI

// Define a protocol for map annotations
protocol MapAnnotationProtocol: Identifiable {
    var coordinate: CLLocationCoordinate2D { get set }
    var onTap: (() -> Void)? { get set }
}

// Update the CustomMapAnnotation to conform to the updated protocol
struct CustomMapAnnotation: MapAnnotationProtocol {
    var id: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var content: AnyView
    var onTap: (() -> Void)?  // Callback for button tap
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, content: AnyView, onTap: (() -> Void)? = nil) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.onTap = onTap
    }
}
