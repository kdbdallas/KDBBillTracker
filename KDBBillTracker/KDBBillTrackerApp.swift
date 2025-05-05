//
//  KDBBillTrackerApp.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/20/25.
//

import SwiftUI
import SwiftData

@main
struct KDBBillTrackerApp: App {

    let modelContainer: ModelContainer
    var viewModel: BillsViewModel

    @UIApplicationDelegateAdaptor private var appDelegate: BillsAppDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bills.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        self.modelContainer = sharedModelContainer

        viewModel = BillsViewModel(modelContext: modelContainer.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            MainBillView()
        }
        .modelContainer(modelContainer)
        .environment(viewModel)
    }
}

extension ModelContainer{
    static let previewContainer: ModelContainer? = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try? ModelContainer(for: Bills.self, configurations: config)

        return container
    }()
}

class BillsAppDelegate: NSObject, UIApplicationDelegate, ObservableObject, @preconcurrency UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self

        return true
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        var notificationActionName = ""

        switch response.actionIdentifier {
        case "snoozeAction":
            notificationActionName = BillNotificationActionName.snooze.rawValue
            break

        case "LogPaymentAction":
            notificationActionName = BillNotificationActionName.logPayment.rawValue
            break

        default:
            notificationActionName = BillNotificationActionName.openApp.rawValue
              break
        }
        
        NotificationCenter.default.post(name: Notification.Name(notificationActionName), object: nil, userInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //displaying the ios local notification when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
}
