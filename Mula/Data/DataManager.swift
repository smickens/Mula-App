//
//  DataManager.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import Firebase
import FirebaseDatabase

@Observable
final class DataManager {

    static let shared = DataManager()

    private init() {
        let dbRef = Database.database().reference()
        accountRef = dbRef.child("account")
        importBatchRef = dbRef.child("importBatch")
        transactionRef = dbRef.child("transaction")

        loadData()
    }

    internal var accountRef: DatabaseReference
    internal var importBatchRef: DatabaseReference
    internal var transactionRef: DatabaseReference

    var accounts: [Account] = []
    var importBatches: [ImportBatch] = []
    var transactions: [Transaction] = []

    func loadData() {
        loadAccounts()
        loadImportBatches()
        loadTransactions()
    }

    // MARK: - Transactions Queries

    func transactionsSortedByDate(with year: String, and month: String) -> [Transaction] {
        transactions(with: year, and: month).sorted { $0.date > $1.date }
    }

    func transactions(with year: String, and month: String) -> [Transaction] {
        transactions.filter { $0.date.year == year && $0.date.month == month }
    }

    func transactions(with year: String, and month: String, in category: TransactionCategory) -> [Transaction] {
        let filtered = transactions(with: year, and: month)
        return filtered.filter { $0.category == category }
    }

    func totalTransactions(with year: String, and month: String, in category: TransactionCategory) -> Double {
        let filtered = transactions(with: year, and: month, in: category)
        return filtered.reduce(0.0) { $0 + $1.amount }
    }

    // MARK: - Trends
    
    struct CategorySpending: Identifiable {
        var id: TransactionCategory { category }
        let category: TransactionCategory
        let total: Double
    }
    
    struct MonthlySpending: Identifiable {
        let id = UUID()
        let date: Date
        var spendingByCategory: [TransactionCategory: Double]
    }
    
    func spendingData(for timeRange: TrendsView.TimeRange) -> (totalSpending: Double, averageMonthlySpending: Double, topCategory: String, spendingByCategory: [CategorySpending], spendingByMonth: [MonthlySpending]) {
        let calendar = Calendar.current
        let today = Date()
        let excludedCategories: Set<TransactionCategory> = [.transfer, .creditCardPayment, .income]
        
        var startDate: Date
        var numberOfMonths: Int
        
        switch timeRange {
        case .oneMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
            numberOfMonths = 1
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: today)!
            numberOfMonths = 3
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: today)!
            numberOfMonths = 6
        case .oneYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
            numberOfMonths = 12
        }
        
        let filteredTransactions = transactions.filter { $0.date >= startDate && $0.type == .expense && !excludedCategories.contains($0.category) }
        
        let totalSpending = filteredTransactions.reduce(0) { $0 + $1.amount }
        let averageMonthlySpending = totalSpending / Double(numberOfMonths)
        
        var spendingByCategoryDict = [TransactionCategory: Double]()
        for transaction in filteredTransactions {
            spendingByCategoryDict[transaction.category, default: 0] += transaction.amount
        }
        
        let spendingByCategory = spendingByCategoryDict.map { CategorySpending(category: $0.key, total: $0.value) }.sorted { $0.total > $1.total }
        
        let topCategory = spendingByCategory.first?.category.displayName ?? "N/A"
        
        // Group by month
        let groupedByMonth = Dictionary(grouping: filteredTransactions) { (transaction) -> Date in
            return calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date))!
        }
        
        var spendingByMonth: [MonthlySpending] = []
        for (month, transactions) in groupedByMonth {
            var monthlySpendingByCategory = [TransactionCategory: Double]()
            for transaction in transactions {
                monthlySpendingByCategory[transaction.category, default: 0] += transaction.amount
            }
            spendingByMonth.append(MonthlySpending(date: month, spendingByCategory: monthlySpendingByCategory))
        }
        
        spendingByMonth.sort { $0.date < $1.date }
        
        return (totalSpending, averageMonthlySpending, topCategory, spendingByCategory, spendingByMonth)
    }

    // MARK: Helper functions

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
