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
    @State var selectedDate = DateComponents()
    @State private var billsToShow: [Bills] = []
    
    static let billDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    static var today: Date { Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: Date()).date ?? Date() }
    static var past: Date { Date.distantPast }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {

            let nextDates = Set(bills.map { Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: $0.nextDueDate) })

            CalendarView(
                selectedDateComponents: $selectedDate,
                preselectedDates: nextDates
            )
            .onChange(of: selectedDate) { _, _ in
                if selectedDate.year != nil {
                    let filteredBills = bills.filter {
                        let nextDueDateComp = Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: $0.nextDueDate)

                        return nextDueDateComp == selectedDate
                    }
                    
                    billsToShow = filteredBills
                } else {
                    billsToShow = bills
                }
            }
                
            List {
                ForEach(billsToShow) { item in
                    NavigationLink {
                        BillDetailView.init(billID: item.persistentModelID)
                    } label: {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.title)
                                .frame(maxWidth: 30)
                            
                            Spacer()
                                .frame(minWidth: 10, idealWidth: 14, maxWidth: 30)
                            
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

                billsToShow = bills
                
                await viewModel.setupReminders(bills: billsToShow)
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
