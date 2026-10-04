import Foundation
import SwiftUI
import SwiftData

struct ExportService {
    static func generateCSV(from transactions: [Transaction]) -> URL? {
        var csvString = "Дата,Тип,Категорія,Коментар,Сума\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for t in transactions {
            let date = formatter.string(from: t.date)
            let type = t.type
            let category = t.category.replacingOccurrences(of: ",", with: " ")
            let comment = t.comment.replacingOccurrences(of: ",", with: " ")
            let amount = String(format: "%.2f", t.amount)
            
            csvString.append("\(date),\(type),\(category),\(comment),\(amount)\n")
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("FinanceExport.csv")
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
}
