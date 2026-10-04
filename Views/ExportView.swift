import SwiftUI
import SwiftData

struct ExportView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var fileURL: URL?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Експорт даних у форматі CSV (сумісно з Excel)")
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let url = fileURL {
                    ShareLink(item: url) {
                        Text("Поділитися файлом")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                } else {
                    Button("Згенерувати звіт") {
                        fileURL = ExportService.generateCSV(from: transactions)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Експорт")
        }
    }
}
