//
//  AddBillView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 3/7/25.
//

import SwiftUI
import SwiftData

struct AddBillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BillsViewModel.self) private var viewModel: BillsViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        Form {
            Section("Bill Details") {
                Text("TEST")
            }
        }
        
        Text("Add Bill")
            .presentationDetents([.large])
            .presentationBackgroundInteraction(.disabled)
            .presentationDragIndicator(.visible)
    }
}

#Preview {
    let container = ModelContainer.previewContainer!
    let vm: BillsViewModel = BillsViewModel(modelContext: container.mainContext)
    
    AddBillView()
        .modelContainer(container)
        .environment(vm)
}
