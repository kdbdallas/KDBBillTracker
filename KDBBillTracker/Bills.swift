//
//  Bills.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/20/25.
//

import Foundation
import SwiftUI
import SwiftData

enum RepeatInterval: Codable {
    case never
    case monthly
    case semiMonthly
    case biMonthly
    case weekly
    case biWeekly
    case daily
    case quarterly
    case semiannual
    case annual
}

struct Tags: Codable {
    let tag: String
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
    var tags: [Tags]
    var nextDueDate: Date?

    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, tags: [String] = [], id: UUID = UUID()) {
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
        
        var givenTags: [Tags] = []
        
        tags.map { $0 }.forEach {
            givenTags.append(Tags(tag: $0))
        }

        self.tags = givenTags
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
    var tags: [Tags]
    var nextDueDate: Date?
    
    init(name: String, amountDue: Double, startingDueDate: Date = Date.now, icon: String = "dollarsign.circle", repeats: RepeatInterval = .never, paidAutomatically: Bool = false, paymentURL: String? = nil, reminder: Bool = false, remindDaysBefore: Int = 0, startingBalance: Double? = nil, endDate: Date? = nil, tags: [String] = [], id: UUID = UUID()) {
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
        
        var givenTags: [Tags] = []
        
        tags.map { $0 }.forEach {
            givenTags.append(Tags(tag: $0))
        }

        self.tags = givenTags
    }
}
