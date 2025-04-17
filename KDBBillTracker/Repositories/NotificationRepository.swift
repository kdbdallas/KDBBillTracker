//
//  NotificationRepository.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 4/15/25.
//

import Foundation
import NotificationCenter
import SwiftData

final class NotificationRepository {
    func setupLocalReminder(billName: String, reminderDate: DateComponents, dueDate: Date, amount: Double, dueDateOffset: String, billID: PersistentIdentifier) async -> String? {

        let billIDData = try? JSONEncoder().encode(billID)
        guard let billIDData = billIDData else { return nil }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderDate, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Bill: \(billName)"
        content.body = "\(dueDateOffset)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "reminderCategory"
        content.userInfo = ["BillID" : billIDData]
        
        let action1 = UNNotificationAction(identifier: "snoozeAction", title: "Snooze", options: [])
        let action2 = UNNotificationAction(identifier: "LogPaymentAction", title: "Log Payment", options: [])

        let category = UNNotificationCategory(identifier: "reminderCategory", actions: [action1, action2], intentIdentifiers: [], options: [])

        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.setNotificationCategories([category])

        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            
            return uuidString
        } catch {
            print("Error adding notification: \(error)")
            
            return nil
        }
    }
    
    func cancelLocalReminder(uuidString: String) async {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuidString])
    }
    
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let notificationSettings = center.notificationSettings
            
            async let authStatus = notificationSettings().authorizationStatus
            
            if await authStatus == .notDetermined {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } else {
                return true
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
        
        return false
    }
}
