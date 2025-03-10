//
//  Bills.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/20/25.
//

import Foundation
import SwiftUI
import SwiftData

enum RepeatInterval: String, Identifiable, Codable, CaseIterable {
    var id: RepeatInterval { self }
    
    case never = "Never"
    case monthly = "Monthly"
    case semiMonthly = "Semi-Monthly"
    case biMonthly = "Bi-Monthly"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case daily = "Daily"
    case quarterly = "Quarterly"
    case semiannual = "Semi-Annual"
    case annual = "Annual"
}

@Model
final class Bills {
    #Unique<Bills>([\.id], [\.name])
    
    var id: UUID
    var name: String
    var icon: String
    var repeatInterval: RepeatInterval
    var startingDueDate: Date
    var amountDue: Double
    var paidAutomatically: Bool
    var paymentURL: String?
    var reminder: Bool
    var remindDaysBefore: Int
    var startingBalance: Double?
    var endDate: Date?
    var nextDueDate: Date

    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.repeatInterval = repeats
        self.startingDueDate = startingDueDate
        self.amountDue = amountDue
        self.paidAutomatically = paidAutomatically
        self.paymentURL = paymentURL
        self.reminder = reminder
        self.remindDaysBefore = remindDaysBefore
        self.endDate = endDate
        self.nextDueDate = startingDueDate
    }
    
    func calculateNextDueDate() {
        if nextDueDate < Date.now {
            let calendar = Calendar.current
            
            switch repeatInterval {
            case .daily:
                nextDueDate = calendar.date(byAdding: .day, value: 1, to: nextDueDate) ?? nextDueDate
            case .weekly:
                nextDueDate = calendar.date(byAdding: .day, value: 7, to: nextDueDate) ?? nextDueDate
            case .biWeekly:
                nextDueDate = calendar.date(byAdding: .day, value: 14, to: nextDueDate) ?? nextDueDate
            case .monthly:
                nextDueDate = calendar.date(byAdding: .month, value: 1, to: nextDueDate) ?? nextDueDate
            case .biMonthly:
                nextDueDate = calendar.date(byAdding: .month, value: 2, to: nextDueDate) ?? nextDueDate
            case .semiMonthly:
                nextDueDate = calendar.date(byAdding: .day, value: 15, to: nextDueDate) ?? nextDueDate
            case .quarterly:
                nextDueDate = calendar.date(byAdding: .month, value: 3, to: nextDueDate) ?? nextDueDate
            case .semiannual:
                nextDueDate = calendar.date(byAdding: .month, value: 6, to: nextDueDate) ?? nextDueDate
            case .annual:
                nextDueDate = calendar.date(byAdding: .year, value: 1, to: nextDueDate) ?? nextDueDate
            case .never:
                nextDueDate = startingDueDate
            }
        }
    }
}

struct BillDataHolder: Codable {
    var id: UUID
    var name: String
    var icon: String
    var repeatInterval: RepeatInterval
    var startingDueDate: Date
    var amountDue: Double
    var paidAutomatically: Bool
    var paymentURL: String?
    var reminder: Bool
    var remindDaysBefore: Int
    var startingBalance: Double?
    var endDate: Date?
    var nextDueDate: Date?
    
    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.repeatInterval = repeats
        self.startingDueDate = startingDueDate
        self.amountDue = amountDue
        self.paidAutomatically = paidAutomatically
        self.paymentURL = paymentURL
        self.reminder = reminder
        self.remindDaysBefore = remindDaysBefore
        self.endDate = endDate
    }
}
