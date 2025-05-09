//
//  String+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 20.10.2023.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func toInt() -> Int? {
        return Int(self)
    }
    
    func toURL() -> URL? {
        return URL(string: self)
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
    static func randomStringWithDigits(_ numberOfDigits: Int, prefix: String = "seb3") -> String {
        // Ensure numberOfDigits is at least 6
        let totalDigits = numberOfDigits < 6 ? 6 : numberOfDigits

        // Generate a random string with the last 6 digits
        let randomSuffix = String(format: "%06d", arc4random_uniform(1000000))

        // Combine with the fixed "seb3" prefix
        let result = prefix + String(randomSuffix.suffix(totalDigits - 4))

        return result
    }
    
    static func randomStringWithDigitsAndChars(_ numberOfDigits: Int) -> String {
        // Generate a random string with the specified length
        let randomString = (0..<numberOfDigits).map { _ in
            let isDigit = Bool.random()
            if isDigit {
                // Generate a random digit
                return String(Int.random(in: 0...9))
            } else {
                // Generate a random uppercase letter
                let randomUppercaseLetter = String(UnicodeScalar(Int.random(in: 65...90))!)
                return randomUppercaseLetter
            }
        }.joined()

        return randomString
    }
    
    func extractFirstTwoAndLastTwoDigits() -> (String, String) {
        var firstTwo = ""
        var lastTwo = ""
        
        let digits = self.filter { $0.isNumber }
        let digitCount = digits.count
        
        if digitCount >= 2 {
            firstTwo = String(digits.prefix(2))
            lastTwo = String(digits.suffix(2))
        } else if digitCount == 1 {
            // If there's only one digit, it will be both the first and last.
            firstTwo = digits
            lastTwo = digits
        }
        
        return (firstTwo, lastTwo)
    }
}
