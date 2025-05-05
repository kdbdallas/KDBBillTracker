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

    var showLogPaymentView: Bool = false
    var notificationBillID: PersistentIdentifier

    init(modelContext: ModelContext) {
        self.context = modelContext

        repositoryActor = BillRepository(modelContainer: self.context.container)
        
        do {
            try notificationBillID = .identifier(for: "", entityName: "", primaryKey: "")
        } catch {
            print("Unable to create blank PersistentIdentifier with error: \(error)")
            fatalError()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationAction(_:)), name: Notification.Name(BillNotificationActionName.snooze.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationAction(_:)), name: Notification.Name(BillNotificationActionName.logPayment.rawValue), object: nil)
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
            let todayDate = DateHelper().reminderTodayDateTime()
            
            for bill in bills {
                if bill.reminder && !bill.scheduledReminder {
                    guard let nextRemindDate = bill.nextRemindDate else { continue }

                    let (nextRemindDateTime, nextRemindDateComps) = DateHelper().nextReminderDateTimeAndComps(nextRemindDate: nextRemindDate)
                    
                    // Check if remind date is in the future
                    if nextRemindDateTime >= todayDate {
                        let reminderUUID = await NotificationRepository().setupLocalReminder(billName: bill.name, reminderDate: nextRemindDateComps, dueDate: bill.nextDueDate, amount: bill.amountDue, dueDateOffset: bill.dueDateOffsetString(), billID: bill.persistentModelID)
                        
                        guard let reminderUUID = reminderUUID else { continue }
                        
                        bill.reminderUUID = reminderUUID
                        bill.scheduledReminder = true
                    }
                }
            }
        }
    }

    @objc func handleNotificationAction(_ notification: Notification) {
        Task {
            guard let userInfo = notification.userInfo else { return }
            guard let billIDData = userInfo["BillID"] as? Data else { return }
            
            do {
                let billID = try JSONDecoder().decode(PersistentIdentifier.self, from: billIDData)
                
                let notificationName = notification.name.rawValue
                
                switch notificationName {
                case BillNotificationActionName.snooze.rawValue:
                    await repositoryActor.snoozeNotification(billID: billID)
                    break
                    
                case BillNotificationActionName.logPayment.rawValue:
                    notificationBillID = billID
                    showLogPaymentView = true
                    break
                    
                default:
                    // OpenApp
                    break
                }
            } catch {
                print("Unable to decode PersistentIdentifier")
                
                return
            }
        }
    }
}
