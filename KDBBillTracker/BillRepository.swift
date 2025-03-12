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
    
    func fetchBills() async throws -> [PersistentIdentifier] {
        let today = Calendar.current.startOfDay(for: Date.now)
        let past = Date.distantPast
        let descriptor = FetchDescriptor<Bills>(
            predicate: #Predicate { ($0.nextDueDate >= today && $0.lastPaid ?? past != $0.nextDueDate) || ($0.nextDueDate < today && $0.lastPaid ?? past < $0.nextDueDate) },
            sortBy: [
                .init(\.nextDueDate)
            ]
        )
        
        var billIDs: [PersistentIdentifier] = []
        
        do {
            let fetched = try context.fetch(descriptor)
            fetched.map { $0 }.forEach {
                billIDs.append($0.persistentModelID)
            }
            
            return billIDs
        } catch {
            throw error
        }
    }
    
    func addDummyBills() async throws {
        // Add dummy bills
        let dummyBills = [BillDataHolder(name: "Bill 1", amountDue: 100),
                          BillDataHolder(name: "Bill 2", amountDue: 125.75, startingDueDate: Date.now.addingTimeInterval(86400), repeats: .weekly),
                          BillDataHolder(name: "Bill 3", amountDue: 55.5, startingDueDate: Date.now.addingTimeInterval(86400*2), repeats: .monthly)]

        for bill in dummyBills {
            try await addBill(bill)
        }
    }

    func addBill(_ bill: BillDataHolder) async throws {
        let newBill = Bills(name: bill.name, amountDue: bill.amountDue, startingDueDate: bill.startingDueDate, icon: bill.icon, repeats: bill.repeatInterval, paidAutomatically: bill.paidAutomatically, paymentURL: bill.paymentURL, reminder: bill.reminder, remindDaysBefore: bill.remindDaysBefore, startingBalance: bill.startingBalance, endDate: bill.endDate, id: bill.id)

        context.insert(newBill)

        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    func deleteBill(id: PersistentIdentifier) async throws {
        guard let bill = context.model(for: id) as? Bills else {
            throw BillRepositoryError.noObjectForID
        }
        
        context.delete(bill)
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    func addBillPayment(billID: PersistentIdentifier, payment: BillPaymentDataHolder) async throws {
        guard let bill = context.model(for: billID) as? Bills else {
            throw BillRepositoryError.noObjectForID
        }

        let newPayment = BillPayments(bill: bill, amount: payment.amount, date: payment.date, note: payment.note, id: payment.id)

        bill.addPayment(payment: newPayment)
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
