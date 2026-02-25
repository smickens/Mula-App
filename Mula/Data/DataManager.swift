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

    func transactions(with year: String, and month: String, in category: any TransactionCategoryProtocol) -> [Transaction] {
        let filtered = transactions(with: year, and: month)
        return filtered.filter { $0.category.id == category.id }
    }

    func totalTransactions(with year: String, and month: String, in category: any TransactionCategoryProtocol) -> Decimal {
        let filtered = transactions(with: year, and: month, in: category)
        return filtered.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Breakdown

    func transactions(from startDate: Date, to endDate: Date) -> [Transaction] {
        return transactions.filter { $0.date >= startDate && $0.date <= endDate }
    }

    struct CategorySpending: Identifiable {
        var id = UUID()
        let category: any TransactionCategoryProtocol
        let total: Decimal
    }

    func groupSpendingByCategory(transactions: [Transaction], maxCategories: Int = 6) -> [CategorySpending] {
        guard !transactions.isEmpty else { return [] }

        // 1️⃣ Count spending by category id
        let spendingById: [String: (any TransactionCategoryProtocol, Decimal)] =
            transactions.reduce(into: [:]) { dict, transaction in
                let category = transaction.category
                let key = category.id
                let currentTotal = dict[key]?.1 ?? 0
                dict[key] = (category, currentTotal + transaction.amount)
            }

        // 2️⃣ Sort descending by total
        let sortedSpending = spendingById.values.sorted { $0.1 > $1.1 }

        // 3️⃣ Handle maxCategories & "Other"
        if sortedSpending.count > maxCategories {
            let topSpending = sortedSpending.prefix(maxCategories - 1)
            let otherSpending = sortedSpending.suffix(from: maxCategories - 1)
            let otherTotal = otherSpending.reduce(0) { $0 + $1.1 }

            var result = topSpending.map { CategorySpending(category: $0.0, total: $0.1) }
            // Use a generic "Other" category — you’ll need an actual .other instance
            let otherCategory = TransferCategory.other as any TransactionCategoryProtocol
            result.append(CategorySpending(category: otherCategory, total: otherTotal))
            return result
        } else {
            return sortedSpending.map { CategorySpending(category: $0.0, total: $0.1) }
        }
    }


    func calculateAverageMonthlySpending(forLastMonths months: Int) -> Decimal {
        let calendar = Calendar.current
        let today = Date()
        var totalSpending: Decimal = 0.0
        var monthsWithExpenses = 0

        for i in 0..<months {
            guard let startDate = calendar.date(byAdding: .month, value: -(i + 1), to: today),
                  let endDate = calendar.date(byAdding: .month, value: -i, to: today) else {
                continue
            }
            
            let monthTransactions = transactions(from: startDate, to: endDate)
            if !monthTransactions.isEmpty {
                totalSpending += monthTransactions.reduce(0) { $0 + $1.amount }
                monthsWithExpenses += 1
            }
        }

        return monthsWithExpenses > 0 ? totalSpending / Decimal(monthsWithExpenses) : 0.0
    }

    func mostFrequentCategory(in transactions: [Transaction]) -> (category: any TransactionCategoryProtocol, count: Int)? {
        guard !transactions.isEmpty else { return nil }

        var counts: [String: (any TransactionCategoryProtocol, Int)] = [:]

        for transaction in transactions {
            let category = transaction.category
            let key = category.id

            if let existing = counts[key] {
                counts[key] = (category, existing.1 + 1)
            } else {
                counts[key] = (category, 1)
            }
        }

        return counts.values.max(by: { $0.1 < $1.1 })
    }

    func largestTransaction(in transactions: [Transaction]) -> Transaction? {
        return transactions.max(by: { $0.amount < $1.amount })
    }

    // MARK: Helper functions

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
