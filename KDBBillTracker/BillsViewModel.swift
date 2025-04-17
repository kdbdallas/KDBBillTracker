//
//  BillsViewModel.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/24/25.
//

import Foundation
import SwiftData
import Observation

@MainActor @Observable class BillsViewModel {

    @ObservationIgnored let context: ModelContext
    @ObservationIgnored let repositoryActor: BillRepository
    @ObservationIgnored let reminderSendHour = 09
    @ObservationIgnored let reminderSendMinute = 00

    init(modelContext: ModelContext) {
        self.context = modelContext

        repositoryActor = BillRepository(modelContainer: self.context.container)
    }
    
    func addDummyBills() async {
        do {
            try await repositoryActor.addDummyBills()
        } catch {
            print("Error Adding Dummy Bills with error: \(error)")
        }
    }
    
    func lastPaidDateString(lastPaid: Date?) -> String {
        guard let lastPaidDate = lastPaid else {
            return "Never"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: lastPaidDate)
    }
    
    func setupReminders(bills: [Bills]) async {
        let notificationsAllowed = await NotificationRepository().requestNotificationPermission()

        if notificationsAllowed {
            let calendar = Calendar.current
            
            var today = calendar.dateComponents([.year, .month, .day], from: .now)
            today.hour = reminderSendHour
            today.minute = reminderSendMinute
            
            let todayDate = calendar.date(from: today)
            
            guard let todayDate = todayDate else { return }
            
            for bill in bills {
                if bill.reminder && !bill.shownReminder {
                    guard let nextRemindDate = bill.nextRemindDate else { continue }
                    
                    var nextRemindDateComps = calendar.dateComponents([.year, .month, .day], from: nextRemindDate)
                    nextRemindDateComps.hour = reminderSendHour
                    nextRemindDateComps.minute = reminderSendMinute
                    
                    guard let nextRemindDate = calendar.date(from: nextRemindDateComps) else { continue }
                    
                    // Check if remind date is in the future
                    if nextRemindDate >= todayDate {
                        let reminderUUID = await NotificationRepository().setupLocalReminder(billName: bill.name, reminderDate: nextRemindDateComps, dueDate: bill.nextDueDate, amount: bill.amountDue, dueDateOffset: bill.dueDateOffsetString(), billID: bill.persistentModelID)
                        
                        guard let reminderUUID = reminderUUID else { continue }
                        
                        bill.reminderUUID = reminderUUID
                        bill.shownReminder = true
                    }
                }
            }
        }
    }
}
