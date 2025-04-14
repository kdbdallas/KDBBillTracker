//
//  LogPaymentView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 3/12/25.
//

import SwiftUI
import SwiftData

struct LogPaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BillsViewModel.self) private var viewModel: BillsViewModel
    @Environment(\.dismiss) var dismiss

    @State var billID: PersistentIdentifier
    @State private var bill: Bills = .init(name: "", amountDue: 0)
    @State private var amount: Double = 0.0
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section(bill.name) {
                    HStack {
                        Text("Amount")
                        
                        Spacer()
                        
                        TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                    }
                    
                    DatePicker(selection: $date, displayedComponents: .date) {
                        Text("Paid Date")
                    }
                    
                    HStack {
                        Text("Note")
                        
                        Spacer()
                        
                        TextField(text: $note) {
                            Text("Note")
                        }
                        .multilineTextAlignment(.trailing)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Log Payment")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePayment()
                    }
                }
            }
            .presentationDetents([.large])
            .presentationBackgroundInteraction(.disabled)
            .presentationDragIndicator(.visible)
        }
        .onAppear() {
            if let billFromID = modelContext.model(for: billID) as? Bills {
                bill = billFromID
                amount = bill.amountDue
            }
        }
    }
    
    private func savePayment() {
        let payment = BillPaymentDataHolder(amount: amount, date: date, note: note)

        viewModel.addPayment(billID: billID, payment: payment)
        
        dismiss()
    }
}

#Preview {
    let container = ModelContainer.previewContainer!
    let vm: BillsViewModel = BillsViewModel(modelContext: container.mainContext)
    
    let bill = Bills.init(name: "Test Bill", amountDue: 100)
    
    LogPaymentView(billID: bill.persistentModelID)
        .modelContainer(container)
        .environment(vm)
}
