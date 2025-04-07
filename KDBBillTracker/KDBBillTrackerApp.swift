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
