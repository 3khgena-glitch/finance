import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category).font(.headline)
                if !transaction.comment.isEmpty {
                    Text(transaction.comment).font(.caption).foregroundColor(.secondary)
                }
                Text(transaction.date, format: .dateTime.day().month().year())
                    .font(.caption2).foregroundColor(.gray)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: "UAH"))
                .foregroundColor(transaction.type == TransactionType.income.rawValue ? .green : .red)
                .fontWeight(.semibold)
        }
    }
}
