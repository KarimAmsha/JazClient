//
//  Int+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 11.11.2023.
//

import Foundation

extension Int {    
    func toString() -> String {
        return String(self)
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func toEnglish() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
