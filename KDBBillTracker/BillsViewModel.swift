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

    @ObservationIgnored let modelContainer: ModelContainer
    @ObservationIgnored let repositoryActor: BillRepository

    var bills: [Bills] = []
    var billDates: Set<DateComponents> = []
    let context: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        repositoryActor = BillRepository(modelContainer: self.modelContainer)
        context = ModelContext(modelContainer)
    }

    func fetchBills() async {
        bills.removeAll()
        billDates.removeAll()

        do {
            var billIDs = try await repositoryActor.fetchBills()
            
            if billIDs.isEmpty {
                try await repositoryActor.addDummyBills()
                billIDs = try await repositoryActor.fetchBills()
            }
            
            for billID in billIDs {
                guard let bill = context.model(for: billID) as? Bills else {
                    continue
                }
                
                bills.append(bill)

                billDates.insert(Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: bill.startingDueDate))
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
