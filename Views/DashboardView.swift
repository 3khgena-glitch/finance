import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var amountString: String = ""
    @State private var type: TransactionType = .expense
    @State private var date: Date = Date()
    @State private var comment: String = ""
    
    var balance: Double {
        transactions.reduce(0) { total, t in
            t.type == TransactionType.income.rawValue ? total + t.amount : total - t.amount
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text(Date(), format: .dateTime.day().month().year())
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Сьогодні - Залишок")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(balance, format: .currency(code: "UAH"))
                            .font(.title2)
                            .bold()
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    
                    Picker("Вид операції", selection: $type) {
                        Text("Видача").tag(TransactionType.expense)
                        Text("Отримання").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Опис", text: $comment)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Сума", text: $amountString)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: saveTransaction) {
                        Text("Зберегти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(amountString.isEmpty)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Останні операції")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        HStack {
                            Text("Дата").bold().frame(maxWidth: .infinity, alignment: .leading)
                            Text("Опис").bold().frame(maxWidth: .infinity, alignment: .leading)
                            Text("Сума").bold().frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        ForEach(transactions.prefix(5)) { t in
                            HStack {
                                Text(t.date, format: .dateTime.day().month())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(t.comment)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Text(t.amount, format: .currency(code: "UAH"))
                                    .foregroundColor(t.type == TransactionType.income.rawValue ? .green : .red)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .listStyle(.plain)
                }
                
                NavigationLink(destination: HistoryView()) {
                    Text("Детально")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Облік")
            .navigationBarHidden(true)
        }
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")), amount > 0 else { return }
        let transaction = Transaction(amount: amount, type: type, date: date, category: "Загальна", comment: comment)
        context.insert(transaction)
        
        amountString = ""
        comment = ""
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        let top5 = Array(transactions.prefix(5))
        for index in offsets {
            context.delete(top5[index])
        }
    }
}
