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
}
