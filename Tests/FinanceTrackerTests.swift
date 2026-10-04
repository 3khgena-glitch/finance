import XCTest
@testable import FinanceTracker

final class FinanceTrackerTests: XCTestCase {
    func testBalanceCalculation() {
        let t1 = Transaction(amount: 1000, type: .income, date: Date(), category: "ЗП")
        let t2 = Transaction(amount: 300, type: .expense, date: Date(), category: "Їжа")
        
        let transactions = [t1, t2]
        
        let balance = transactions.reduce(0) { total, t in
            t.type == TransactionType.income.rawValue ? total + t.amount : total - t.amount
        }
        
        XCTAssertEqual(balance, 700.0)
    }
}
