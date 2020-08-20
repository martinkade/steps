//
//  FitnessDateRange.swift
//  Runner
//
//  Created by mediaBEAM on 18.08.20.
//

import UIKit

class FitnessDateRange: NSObject {
    
    var startDate: Date?
    var endDate: Date?
    
    override init() {
        super.init()
    }
    
    class var today: FitnessDateRange {
        let range = FitnessDateRange()
        range.startDate = Date().midnight
        range.endDate = Date()
        
        NSLog("today: \(range.description)")
        return range
    }
    
    class var week: FitnessDateRange {
        let range = FitnessDateRange()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var startDateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: Date())
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.day = (startDateComponents.day ?? 0) - (startDateComponents.weekday ?? 0) + 2
        startDateComponents.calendar = calendar
        
        range.startDate = calendar.date(from: startDateComponents)
        range.endDate = Date()
        
        NSLog("week: \(range.description)")
        return range
    }
    
    class var lastWeek: FitnessDateRange {
        let range = FitnessDateRange()
        
        let date = Date().addingTimeInterval(-3600 * 24 * 7)
        
        range.startDate = date.startOfWeek
        range.endDate = date.endOfWeek
        
        NSLog("lastWeek: \(range.description)")
        return range
    }
    
    class var allTime: FitnessDateRange {
        let range = FitnessDateRange()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var startDateComponents = DateComponents()
        startDateComponents.day = 17//24
        startDateComponents.month = 8
        startDateComponents.year = 2020
        startDateComponents.calendar = calendar
        
        range.startDate = calendar.date(from: startDateComponents)
        range.endDate = Date()
        
        NSLog("allTime: \(range.description)")
        return range
    }
    
    override var description: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.timeZone = TimeZone.current
            guard let startDate = startDate, let endDate = endDate else {
                return "Missing start or end date"
            }
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
    
}

extension Date {
    
    var midnight: Date? {
        get {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            return calendar.startOfDay(for: self)
        }
    }
    
    var startOfWeek: Date? {
        get {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            var components = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: self)
            components.hour = 0
            components.minute = 0
            components.day = (components.day ?? 0) - (components.weekday ?? 0) + 2
            components.calendar = calendar
            
            return calendar.date(from: components)
        }
    }
    
    var endOfWeek: Date? {
        get {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            var components = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: self)
            components.hour = 23
            components.minute = 59
            components.day = (components.day ?? 0) + (7 - (components.weekday ?? 0)) + 1
            components.calendar = calendar
            
            return calendar.date(from: components)
        }
    }
    
    var isToday: Bool {
        get {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            return calendar.isDateInToday(self)
        }
    }

    var isThisWeek: Bool {
        get {
            let now = Date()
            let nowStart = now.startOfWeek
            let nowEnd = now.endOfWeek
            guard let s = nowStart, let e = nowEnd else {
                return false
            }
            return self.compare(s) == ComparisonResult.orderedDescending && self.compare(e) == ComparisonResult.orderedAscending
        }
    }
    
    var isLastWeek: Bool {
        get {
            let now = Date().addingTimeInterval(-3600 * 24 * 7)
            let nowStart = now.startOfWeek
            let nowEnd = now.endOfWeek
            guard let s = nowStart, let e = nowEnd else {
                return false
            }
            return self.compare(s) == ComparisonResult.orderedDescending && self.compare(e) == ComparisonResult.orderedAscending
        }
    }
    
}
