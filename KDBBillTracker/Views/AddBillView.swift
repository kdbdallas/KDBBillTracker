//
//  AddBillView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 3/7/25.
//

import SwiftUI
import SwiftData
import SFSymbolsPicker

struct AddBillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNewBill()
                    }
                }
            }
            .presentationDetents([.large])
            .presentationBackgroundInteraction(.disabled)
            .presentationDragIndicator(.visible)
        }
    }

    private func saveNewBill() {
        let billEndDate: Date?

        if hasEndDate {
            billEndDate = endDate
        } else {
            billEndDate = nil
        }
        
        let bill = Bills(name: billName, amountDue: amountDue, startingDueDate: nextDueDate, icon: icon, repeats: repeatInterval, paidAutomatically: paidAutomatically, paymentURL: paymentURL, reminder: reminderEnabled, remindDaysBefore: remindDaysBefore, startingBalance: startingBalance, endDate: billEndDate)
        
        modelContext.insert(bill)
        
        try? modelContext.save()
        
        dismiss()
    }
}

#Preview {
    let container = ModelContainer.previewContainer!

    AddBillView()
        .modelContainer(container)
}
