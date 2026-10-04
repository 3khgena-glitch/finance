import Foundation
import SwiftData

struct ImportService {
    static func importCSV(from url: URL, context: ModelContext) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let data = try? String(contentsOf: url, encoding: .utf8) else {
            print("Помилка читання файлу")
            return
        }
        
        let rows = data.components(separatedBy: .newlines)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"
        
        for row in rows {
            if row.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            
            // Визначаємо роздільник (кома або крапка з комою)
            let separator: Character = row.contains(";") ? ";" : ","
            let columns = row.split(separator: separator, omittingEmptySubsequences: false)
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") }
            
            // Потрібно щонайменше 3 колонки: Дата, Тип, Сума
            guard columns.count >= 3 else { continue }
            
            let dateString = columns[0]
            // Якщо не вдається розпізнати дату, це або заголовок, або підсумок — ігноруємо рядок
            guard let date = formatter.date(from: dateString) ?? fallbackFormatter.date(from: dateString) else { continue }
            
            let typeString = columns[1]
            let amountString = columns[2].replacingOccurrences(of: ",", with: ".")
            let comment = columns.count > 3 ? columns[3] : ""
            
            guard let amountValue = Double(amountString) else { continue }
            
            // Робимо суму додатною (модуль), оскільки програма сама розрізняє прибуток/витрату
            let amount = abs(amountValue)
            guard amount > 0 else { continue }
            
            let type: TransactionType = typeString.localizedCaseInsensitiveContains("Отримано") ? .income : .expense
            
            let transaction = Transaction(amount: amount, type: type, date: date, category: "Імпортовано", comment: comment)
            context.insert(transaction)
        }
    }
}
