import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var fileURL: URL?
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                VStack(spacing: 16) {
                    Text("Експорт даних")
                        .font(.headline)
                    
                    if let url = fileURL {
                        ShareLink(item: url) {
                            Text("Поділитися файлом")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Button("Згенерувати звіт (CSV)") {
                            fileURL = ExportService.generateCSV(from: transactions)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                VStack(spacing: 16) {
                    Text("Імпорт даних")
                        .font(.headline)
                    Text("Використовуйте CSV файл, збережений з вашої таблиці.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Завантажити історію (CSV)") {
                        isImporting = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Дані")
            
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    ImportService.importCSV(from: url, context: context)
                case .failure(let error):
                    print("Помилка імпорту: \(error.localizedDescription)")
                }
            }
        }
    }
}
