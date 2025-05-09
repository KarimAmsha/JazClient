//
//  Double+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 8.11.2023.
//

import Foundation

extension Double {
    func rounded(toDecimalPlaces decimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
    }
    
    func toInt() -> Int {
        return Int(self)
    }
    
    func toString() -> String {
        return String(self)
    }
    
    func formattedString(toDecimalPlaces decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
    
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toEnglish() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    func percentage(of total: Double) -> Double {
        guard total > 0 else { return 0.0 } // Protect against division by zero
        
        return (self / total) * 100.0
    }
}

