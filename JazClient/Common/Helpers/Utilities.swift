//
//  Utilities.swift
//  Khawi
//
//  Created by Karim Amsha on 7.11.2023.
//

import Foundation
import MapKit
import SwiftUI

class Utilities: NSObject {
    static func convertDateStringToDate(stringDate: String, outputFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // Input format
        guard let date = dateFormatter.date(from: stringDate) else {
            return nil // Return nil if input string is not in the expected format
        }
        
        dateFormatter.dateFormat = outputFormat // Output format
        return dateFormatter.string(from: date)
    }

    // Generalized getSkeletonList function
    static func getSkeletonList<Content: View>(count: Int, @ViewBuilder content: @escaping (Int) -> Content) -> some View {
        VStack {
            ForEach(0..<count, id: \.self) { index in
                content(index)
            }
        }
    }

    static func generateChatID(user1ID: String, user2ID: String) -> String {
        return "\(user1ID)-\(user2ID)"
    }
    
    static func extractUserIDs(from chatID: String) -> (user1ID: String, user2ID: String)? {
        let components = chatID.split(separator: "-")
        guard components.count == 2 else {
            // Invalid chat ID format
            return nil
        }
        let user1ID = String(components[0])
        let user2ID = String(components[1])
        return (user1ID, user2ID)
    }

    // Helper function to get the address for a given coordinate
    static func getAddress(for coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var addressComponents: [String] = []

                if let thoroughfare = placemark.thoroughfare {
                    addressComponents.append(thoroughfare)
                }
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                if let name = placemark.name {
                    addressComponents.append(name)
                }

    //                if let administrativeArea = placemark.administrativeArea {
    //                    addressComponents.append(administrativeArea)
    //                }
    //                if let postalCode = placemark.postalCode {
    //                    addressComponents.append(postalCode)
    //                }
                if let country = placemark.country {
                    addressComponents.append(country)
                }

                let formattedAddress = addressComponents.joined(separator: ", ")
                completion(formattedAddress)
            } else {
                completion(LocalizedStringKey.addressNotFound)
            }
        }
    }
}

