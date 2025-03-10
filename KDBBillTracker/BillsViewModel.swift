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

    var bills: [Bills] = []
    var billDates: Set<DateComponents> = []

    init(modelContext: ModelContext) {
        self.context = modelContext

        repositoryActor = BillRepository(modelContainer: self.context.container)
    }

    func fetchBills() async {
        bills.removeAll()
        billDates.removeAll()

        do {
            var billIDs = try await repositoryActor.fetchBills()

            // Populate with Dummy data for testing
            if billIDs.isEmpty {
                try await repositoryActor.addDummyBills()
                billIDs = try await repositoryActor.fetchBills()
            }

            for billID in billIDs {
                guard let bill = context.model(for: billID) as? Bills else {
                    continue
                }

                bill.calculateNextDueDate()
                
                bills.append(bill)

                billDates.insert(Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: bill.nextDueDate))
            }
        } catch {
            print("Error Fetching Bills with error: \(error)")
        }
    }
    
    func addBill(_ bill: BillDataHolder) {
        Task {
            do {
                try await repositoryActor.addBill(bill)
                await fetchBills()
            } catch {
                print("Error adding Bill with error: \(error)")
            }
        }
    }
    
    func deleteBill(at indexSet: IndexSet) {
        Task {
            do {
                for index in indexSet {
                    try await repositoryActor.deleteBill(id: bills[index].persistentModelID)
                }
            } catch {
                print("Can not delete bill with error: \(error)")
            }
        }
    }
}
