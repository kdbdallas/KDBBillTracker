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

    @Query var bills: [Bills]
    
    @State private var showAddBillSheet: Bool = false
    
    static let billDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    init() {
        let today = Calendar.current.startOfDay(for: Date.now)
        let past = Date.distantPast

        let predicate = #Predicate<Bills> {
            ($0.nextDueDate >= today && $0.lastPaid ?? past != $0.nextDueDate) || ($0.nextDueDate < today && $0.lastPaid ?? past < $0.nextDueDate)
        }

        _bills = Query(filter: predicate, sort: \.nextDueDate)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationSplitView {
            MultiDatePicker("Bill Dates", selection: $viewModel.billDates)
                .padding(.horizontal)
                .disabled(true)

            List {
                ForEach(bills) { item in
                    NavigationLink {
                        BillDetailView.init(bill: item)
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
            for index in offsets {
                modelContext.delete(bills[index])
            }

            try? modelContext.save()
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
