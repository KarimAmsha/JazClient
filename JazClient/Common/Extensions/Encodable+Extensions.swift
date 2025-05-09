//
//  Encodable+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 6.11.2023.
//

import Foundation

extension Encodable {
    func toDict() -> [String: Any]? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = jsonObject as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Error converting to dictionary: \(error)")
        }
        return nil
    }
}
