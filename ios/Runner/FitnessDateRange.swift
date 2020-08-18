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
        NSLog("today: startDate=\(String(describing: range.startDate))")
        NSLog("today: endDate=\(String(describing: range.endDate))")
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
        NSLog("week: startDate=\(String(describing: range.startDate))")
        NSLog("week: endDate=\(String(describing: range.endDate))")
        return range
    }
    
    class var lastWeek: FitnessDateRange {
        let range = FitnessDateRange()
        
        let date = Date().addingTimeInterval(-3600 * 24 * 7)
        
        range.startDate = date.startOfWeek
        range.endDate = date.endOfWeek
        NSLog("lastWeek: startDate=\(String(describing: range.startDate))")
        NSLog("lastWeek: endDate=\(String(describing: range.endDate))")
        return range
    }
    
    class var allTime: FitnessDateRange {
        let range = FitnessDateRange()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var startDateComponents = DateComponents()
        startDateComponents.day = 24
        startDateComponents.month = 8
        startDateComponents.year = 2020
        startDateComponents.calendar = calendar
        
        range.startDate = calendar.date(from: startDateComponents)
        range.endDate = Date()
        return range
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
    
}
