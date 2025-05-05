//
//  Date+Helper.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 4/22/25.
//

import Foundation

struct DateHelper {
    static let reminderSendHour = 09
    static let reminderSendMinute = 00
    static let calendar = Calendar.current
    
    func reminderTodayDateTime() -> Date {
        var today = DateHelper.calendar.dateComponents([.year, .month, .day], from: .now)
        today.hour = DateHelper.reminderSendHour
        today.minute = DateHelper.reminderSendMinute
        
        let todayDate = DateHelper.calendar.date(from: today)
        
        guard let todayDate = todayDate else { return Date.now }
        
        return todayDate
    }
    
    func nextReminderDateTimeAndComps(nextRemindDate: Date) -> (Date, DateComponents) {
        var nextRemindDateComps = DateHelper.calendar.dateComponents([.year, .month, .day], from: nextRemindDate)
        nextRemindDateComps.hour = DateHelper.reminderSendHour
        nextRemindDateComps.minute = DateHelper.reminderSendMinute
        
        guard let nextRemindDate = DateHelper.calendar.date(from: nextRemindDateComps) else { return (Date.now, nextRemindDateComps) }
        
        return (nextRemindDate, nextRemindDateComps)
    }
}
