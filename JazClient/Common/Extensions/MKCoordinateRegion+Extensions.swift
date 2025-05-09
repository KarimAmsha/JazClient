//
//  MKCoordinateRegion+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 27.10.2023.
//

import MapKit

extension MKCoordinateRegion {
    func center(at point: CGPoint) -> CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2D(
            latitude: center.latitude - (point.y - UIScreen.main.bounds.height / 2) * span.latitudeDelta / UIScreen.main.bounds.height,
            longitude: center.longitude + (point.x - UIScreen.main.bounds.width / 2) * span.longitudeDelta / UIScreen.main.bounds.width
        )
        return coordinate
    }
}

extension CLLocationCoordinate2D: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
