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
    var lastPaid: Date?
    @Relationship(deleteRule: .cascade, inverse: \BillPayments.bill) var payments: [BillPayments] = []

    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, lastPaid: Date? = nil, id: UUID = UUID()) {
        let startOfStartDueDate = Calendar.current.startOfDay(for: startingDueDate)
        
        self.id = id
        self.name = name
        self.icon = icon
        self.repeatInterval = repeats
        self.startingDueDate = startOfStartDueDate
        self.amountDue = amountDue
        self.paidAutomatically = paidAutomatically
        self.paymentURL = paymentURL
        self.reminder = reminder
        self.remindDaysBefore = remindDaysBefore
        self.endDate = endDate
        self.nextDueDate = startOfStartDueDate
        self.lastPaid = lastPaid
    }
    
    func calculateNextDueDate() {
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
    
    func dueDateOffsetString() -> String {
        var offset = ""
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        
        guard nextDueDate != today else { return "Due Today" }
        
        let daysBetween: Int
        
        if nextDueDate < today {
            daysBetween = calendar.dateComponents([.day], from: nextDueDate, to: today).day ?? 1
            offset = "Overdue by \(String(describing: daysBetween)) day"
        } else {
            daysBetween = calendar.dateComponents([.day], from: today, to: nextDueDate).day ?? 1
            offset = "Due in \(String(describing: daysBetween)) day"
        }
        
        if daysBetween > 1 { offset.append("s") }
        
        return offset
    }
    
    func addPayment(payment: BillPayments) {
        payments.append(payment)
        lastPaid = Calendar.current.startOfDay(for: Date.now)
        calculateNextDueDate()
    }
}

@Model
final class BillPayments {
    #Unique<BillPayments>([\.id], [\.bill])
    
    var id: UUID
    var bill: Bills?
    var amount: Double
    var date: Date
    var note: String

    init(bill: Bills, amount: Double, date: Date = Date.now, note: String = "", id: UUID = UUID()) {
        self.id = id
        self.bill = bill
        self.amount = amount
        self.date = date
        self.note = note
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
    var nextDueDate: Date
    var lastPaid: Date?
    
    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, lastPaid: Date? = nil, id: UUID = UUID()) {
        let startOfStartDueDate = Calendar.current.startOfDay(for: startingDueDate)
        
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
        self.lastPaid = lastPaid
        self.nextDueDate = startOfStartDueDate
    }
}

struct BillPaymentDataHolder: Codable {
    var id: UUID
    var amount: Double
    var date: Date
    var note: String

    init(amount: Double, date: Date = Date.now, note: String = "", id: UUID = UUID()) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}
