import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate = Date()
    
    var filteredTransactions: [Transaction] {
        allTransactions.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Період") {
                        DatePicker("Початок", selection: $startDate, displayedComponents: .date)
                        DatePicker("Кінець", selection: $endDate, displayedComponents: .date)
                    }
                }
                .frame(height: 150)
                
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("Історія")
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredTransactions[index])
        }
    }
}
