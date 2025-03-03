//
//  ContentView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/20/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BillsViewModel.self) private var viewModel: BillsViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationSplitView {
            MultiDatePicker("Bill Dates", selection: $viewModel.billDates)
                .padding(.horizontal)
            
            List {
                ForEach(viewModel.bills) { item in
                    NavigationLink {
                        Text("Item at \(item.name)")
                    } label: {
                        Text(item.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            let vm = viewModel

            Task {
                await vm.fetchBills()
            }
        }
    }

    private func addItem() {
        let addBill = BillDataHolder(name: "New Bill", amountDue: 100.0)

        withAnimation {
            viewModel.addBill(addBill)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteBill(at: offsets)
        }
    }
}

#Preview {
    let container = ModelContainer.previewContainer!
    let vm: BillsViewModel = BillsViewModel(modelContainer: container)
    
    ContentView()
        .modelContainer(container)
        .environment(vm)
}
