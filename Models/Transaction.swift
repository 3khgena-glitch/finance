import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case income = "Отримання"
    case expense = "Видача"
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var type: String
    var date: Date
    var category: String
    var comment: String
    var account: String
    
    init(amount: Double, type: TransactionType, date: Date, category: String, comment: String = "", account: String = "") {
        self.id = UUID()
        self.amount = amount
        self.type = type.rawValue
        self.date = date
        self.category = category
        self.comment = comment
        self.account = account
    }
}
