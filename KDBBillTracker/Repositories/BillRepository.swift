//
//  BillRepository.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/24/25.
//

import Foundation
import SwiftData

enum BillRepositoryError: Error {
    case noObjectForID
}

@ModelActor
actor BillRepository: Sendable {
    
    private var context: ModelContext { modelExecutor.modelContext }
    
    func addDummyBills() async throws {
        let addOneDay = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        let addSevenDays = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        
        var newBill = Bills(name: "Bill 1", amountDue: 100)
        context.insert(newBill)
        
        newBill = Bills(name: "Bill 2", amountDue: 125.75, startingDueDate: addOneDay, repeats: .weekly)
        context.insert(newBill)
        
        newBill = Bills(name: "Bill 3", amountDue: 55.5, startingDueDate: addSevenDays, repeats: .monthly, reminder: true)
        context.insert(newBill)
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }

    func snoozeNotification(billID: PersistentIdentifier) async {
        let bill = context.registeredModel(for: billID) as Bills?

        guard let bill = bill else { return }
        guard let nextRemindDate = bill.nextRemindDate else { return }
        
        let todayDate = DateHelper().reminderTodayDateTime()
        
        let newRemindDate = Calendar.current.date(byAdding: .day, value: 1, to: nextRemindDate)
        guard let newRemindDate = newRemindDate else { return }
        
        let (newRemindDateTime, newRemindDateTimeComps) = DateHelper().nextReminderDateTimeAndComps(nextRemindDate: newRemindDate)

        if newRemindDateTime >= todayDate {
            let reminderUUID = await NotificationRepository().setupLocalReminder(billName: bill.name, reminderDate: newRemindDateTimeComps, dueDate: bill.nextDueDate, amount: bill.amountDue, dueDateOffset: bill.dueDateOffsetString(), billID: bill.persistentModelID)
            
            bill.scheduledReminder = true
            
            guard let reminderUUID = reminderUUID else { return }
            
            bill.reminderUUID = reminderUUID
        }
    }
}
