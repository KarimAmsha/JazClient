//
//  Int64+Extensions.swift
//  AmalMarinFreelancer
//
//  Created by Karim Amsha on 28.12.2023.
//

import Foundation

extension Int64 {
    func getDateStringFromUTC(format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    func getDateString(format: String) -> String {
       let date = Date(timeIntervalSince1970: TimeInterval(self))
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = format
       return dateFormatter.string(from: date)
    }
    
    func getShortDateString() -> String {
       let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dataformatter = DateFormatter.init()
        dataformatter.timeStyle = .short
        return dataformatter.string(from: date)
   }
    
    func getDate(format: String = "MMM dd yyyy") -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return date
    }
    
    func toDate() -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return date
    }
    
    func getDayOfWeekString() -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: date)
        let weekDay = myComponents.weekday
        switch weekDay {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
}
