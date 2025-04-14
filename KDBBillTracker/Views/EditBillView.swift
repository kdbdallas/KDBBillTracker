//
//  EditBillView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 4/13/25.
//

import SwiftUI
import SwiftData
import SFSymbolsPicker

struct EditBillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var billID: PersistentIdentifier
    @State private var bill: Bills = .init(name: "", amountDue: 0)
    
    @State private var icon = "star.fill"
    @State private var isPresented = false
    @State private var billName = ""
    @State private var nextDueDate = Date()
    @State private var repeatInterval: RepeatInterval = .never
    @State private var amountDue: Double = 0.0
    @State private var paidAutomatically = false
    @State private var paymentURL = ""
    @State private var reminderEnabled = true
    @State private var remindDaysBefore = 7
    @State private var startingBalance: Double = 0.0
    @State private var hasEndDate = false
    @State private var endDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    HStack {
                        Button {
                            isPresented.toggle()
                        } label: {
                            Label("Select Icon", systemImage: icon)
                        }
                        .sheet(isPresented: $isPresented, content: {
                            SymbolsPicker(selection: $icon, title: "Choose your symbol", autoDismiss: true)
                        })
                        
                        Spacer()
                        
                        TextField(text: $billName) {
                            Text("New Bill Name")
                        }
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                Section() {
                    DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                    
                    Picker("Repeats", selection: $repeatInterval) {
                        ForEach(RepeatInterval.allCases) { interval in
                            Text(interval.rawValue).tag(interval.rawValue)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                
                Section() {
                    HStack {
                        Text("Amount Due")
                        
                        Spacer()
                        
                        TextField("Amount Due", value: $amountDue, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                    }
                    
                    Toggle("Paid Automatically", isOn: $paidAutomatically)
                }
                
                Section() {
                    HStack {
                        Text("Payment URL")
                        
                        Spacer()
                        
                        TextField("https://", text: $paymentURL)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                    }
                }
                
                Section() {
                    Toggle("Enable Reminder", isOn: $reminderEnabled.animation())
                    
                    if reminderEnabled {
                        HStack {
                            Stepper("Remind Days Before", value: $remindDaysBefore, in: 0...10)
                            
                            Text("\(remindDaysBefore)")
                        }
                    }
                }
                
                Section() {
                    HStack {
                        Text("Starting Balance")
                        
                        Spacer()
                        
                        TextField("Starting Balance", value: $startingBalance, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section() {
                    Toggle("Has End Date", isOn: $hasEndDate.animation())
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
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
                    Text("Edit \(bill.name)")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editBill()
                    }
                }
            }
            .presentationDetents([.large])
            .presentationBackgroundInteraction(.disabled)
            .presentationDragIndicator(.visible)
            .onAppear() {
                bill = modelContext.model(for: billID) as? Bills ?? .init(name: "", amountDue: 0)
                
                icon = bill.icon
                billName = bill.name
                nextDueDate = bill.nextDueDate
                repeatInterval = bill.repeatInterval
                amountDue = bill.amountDue
                paidAutomatically = bill.paidAutomatically
                paymentURL = bill.paymentURL ?? ""
                reminderEnabled = bill.reminder
                remindDaysBefore = bill.remindDaysBefore
                startingBalance = bill.startingBalance ?? 0
                hasEndDate = bill.endDate != nil
                endDate = bill.endDate ?? Date()
            }
        }
    }
    
    private func editBill() {
        let billEndDate: Date?

        if hasEndDate {
            billEndDate = endDate
        } else {
            billEndDate = nil
        }
        
        bill.icon = icon
        bill.name = billName
        bill.nextDueDate = nextDueDate
        bill.repeatInterval = repeatInterval
        bill.amountDue = amountDue
        bill.paidAutomatically = paidAutomatically
        bill.paymentURL = paymentURL
        bill.reminder = reminderEnabled
        bill.remindDaysBefore = remindDaysBefore
        bill.startingBalance = startingBalance
        bill.endDate = billEndDate
        
        try? modelContext.save()
        
        dismiss()
    }
}

#Preview {
    let container = ModelContainer.previewContainer!
    let vm: BillsViewModel = BillsViewModel(modelContext: container.mainContext)
    
    let bill = Bills.init(name: "Test Bill", amountDue: 100)

    EditBillView(billID: bill.persistentModelID)
        .modelContainer(container)
        .environment(vm)
}
