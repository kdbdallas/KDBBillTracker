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
        let addTwoDay = Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now
        
        var newBill = Bills(name: "Bill 1", amountDue: 100)
        context.insert(newBill)
        
        newBill = Bills(name: "Bill 2", amountDue: 125.75, startingDueDate: addOneDay, repeats: .weekly)
        context.insert(newBill)
        
        newBill = Bills(name: "Bill 3", amountDue: 55.5, startingDueDate: addTwoDay, repeats: .monthly, reminder: true)
        context.insert(newBill)
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
