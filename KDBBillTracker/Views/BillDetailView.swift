//
//  BillDetailView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 3/10/25.
//

import SwiftUI
import SwiftData

struct BillDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BillsViewModel.self) private var viewModel: BillsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var bill: Bills
    @State private var presentLogPaymentView = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationView {
            Form {
                Section {
                    VStack {
                        HStack {
                            Spacer()
                            Text(bill.dueDateOffsetString())
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(bill.nextDueDate, style: .date)
                            Spacer()
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Amount Due:")
                        Spacer()
                        Text(bill.amountDue, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    
                    HStack {
                        Text("Repeats:")
                        Spacer()
                        Text(bill.repeatInterval.rawValue)
                    }
                    
                    HStack {
                        Text("Last Paid:")
                        Spacer()
                        Text(viewModel.lastPaidDateString(lastPaid: bill.lastPaid))
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            presentLogPaymentView = true
                        } label: {
                            Text("Log Payment")
                        }
                        .sheet(isPresented: $presentLogPaymentView) {
                            LogPaymentView(bill: bill)
                        }
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            //
                        } label: {
                            Text("Skip Payment")
                        }
                        Spacer()
                    }
                }
                
                Section {
                    Button {
                        //
                    } label: {
                        Text("View Payment History")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(bill.name)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    
                }
            }
        }
    }
}

#Preview {
    let container = ModelContainer.previewContainer!
    let vm: BillsViewModel = BillsViewModel(modelContext: container.mainContext)
    
    let bill = Bills.init(name: "Test Bill", amountDue: 100)
    
    BillDetailView(bill: bill)
        .modelContainer(container)
        .environment(vm)
}
