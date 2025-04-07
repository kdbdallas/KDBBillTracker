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

    @Query(filter: #Predicate<Bills> { bill in
        (bill.nextDueDate >= today && bill.lastPaid ?? past != bill.nextDueDate) || (bill.nextDueDate < today && bill.lastPaid ?? past < bill.nextDueDate)
    }, sort: \.nextDueDate) var bills: [Bills]
    
    @State private var showAddBillSheet: Bool = false
    @State var billDates: Set<DateComponents> = []
    
    static let billDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    static var today: Date { Calendar.current.startOfDay(for: Date.now) }
    static var past: Date { Date.distantPast }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {
            MultiDatePicker("Bill Dates", selection: .init(
                get: {
                    let nextDates = bills.map { Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: $0.nextDueDate) }
                    
                   return Set(nextDates.map { $0 })
                },
                set: {
                    billDates = $0
                }
            ))
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
            .task {
                if bills.isEmpty {
                    await viewModel.addDummyBills()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: showAddBillScreen) {
                        Label("Add Bill", systemImage: "plus")
                    }
                    .sheet(isPresented: $showAddBillSheet) {
                        AddBillView.init()
                    }
                }
            }
        } detail: {
            Text("Select a Bill")
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
