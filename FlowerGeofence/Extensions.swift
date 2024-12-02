//
//  Extensions.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 22/10/24.
//

import Foundation

// Notification names
extension Notification.Name {
    static let locationUpdated = Notification.Name("locationUpdated")
   
}


extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
    
}
