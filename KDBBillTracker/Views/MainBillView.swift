//
//  MainBillView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 2/20/25.
//

import SwiftUI
import SwiftData

struct MainBillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BillsViewModel.self) private var viewModel: BillsViewModel
    
    @State private var showAddBillSheet: Bool = false
    
    static let billDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()

    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationSplitView {
            MultiDatePicker("Bill Dates", selection: $viewModel.billDates)
                .padding(.horizontal)
                .disabled(true)

            List {
                ForEach(viewModel.bills) { item in
                    NavigationLink {
                        Text("View Bill \(item.name)")
                    } label: {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.title)
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.dueDateOffsetString())
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(item.nextDueDate, formatter: MainBillView.billDateFormat)")
                                
                                Text(item.amountDue, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: showAddBillScreen) {
                        Label("Add Bill", systemImage: "plus")
                    }
                    .sheet(isPresented: $showAddBillSheet, content: AddBillView.init)
                }
            }
        } detail: {
            Text("Select a Bill")
        }
        .onAppear {
            let vm = viewModel

            Task {
                await vm.fetchBills()
            }
        }
    }

    private func showAddBillScreen() {
        withAnimation {
            showAddBillSheet.toggle()
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
    let vm: BillsViewModel = BillsViewModel(modelContext: container.mainContext)
    
    MainBillView()
        .modelContainer(container)
        .environment(vm)
}
