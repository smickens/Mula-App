//
//  DataManager.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import Foundation

@Observable
@MainActor
final class DataManager {

    static let shared = DataManager()

    private let firebaseDataSource = FirebaseDataSource()
    private let testDataSource = TestDataSource()
    var dataSource: any DataSource
    private var loadTask: Task<Void, Never>?

    private init() {
        dataSource = firebaseDataSource

        loadData()
    }

    var accounts: [Account] = []
    var accountStatements: [AccountStatement] = []
    var importBatches: [ImportBatch] = []
    var transactions: [Transaction] = []

    var useTestData: Bool = false {
        didSet {
            print("🔄 Switching to \(useTestData ? "TEST" : "FIREBASE") mode")
            dataSource = useTestData ? testDataSource : firebaseDataSource

            print("Force reloading data...")
            loadData()
        }
    }

    func loadData() {
        loadTask?.cancel()

        accounts.removeAll()
        accountStatements.removeAll()
        importBatches.removeAll()
        transactions.removeAll()

        let dataSource = dataSource

        loadTask = Task {
            await reloadData(from: dataSource)
        }
    }

    private func reloadData(from dataSource: any DataSource) async {
        do {
            async let loadedAccounts = dataSource.loadAccounts()
            async let loadedAccountStatements = dataSource.loadAccountStatements()
            async let loadedImportBatches = dataSource.loadImportBatches()
            async let loadedTransactions = dataSource.loadTransactions()

            let (accounts, accountStatements, importBatches, transactions) = try await (
                loadedAccounts,
                loadedAccountStatements,
                loadedImportBatches,
                loadedTransactions
            )

            try Task.checkCancellation()

            self.accounts = accounts
            self.accountStatements = accountStatements
            self.importBatches = importBatches
            self.transactions = transactions

            print("✅ Loaded \(useTestData ? "test" : "Firebase") data: \(accounts.count) accounts, \(accountStatements.count) statements, \(importBatches.count) batches, \(transactions.count) transactions")
        } catch is CancellationError {
            print("ℹ️ Load cancelled.")
        } catch {
            print("❌ Failed to load data: \(error.localizedDescription)")
        }
    }

    // MARK: - Transactions Queries

    func addAccountStatement(_ statement: AccountStatement) {
        Task {
            do {
                try await dataSource.addAccountStatement(statement)
                accountStatements.append(statement)
            } catch {
                print("❌ Failed to add account statement: \(error.localizedDescription)")
            }
        }
    }

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


    func calculateAverageMonthlySpending(
        forLastMonths months: Int,
        endingAt date: Date = Date(),
        minimumMonthlySpending: Decimal = 1000,
        minimumValidMonths: Int = 2
    ) -> Decimal? {
        let calendar = Calendar.current
        var totalSpending: Decimal = 0.0
        var validMonths = 0

        for i in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: date),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
                continue
            }

            let monthSpending = transactions(from: monthInterval.start, to: monthInterval.end)
                .filter { $0.kind.isSpendingAnalyticsEligible }
                .reduce(0) { $0 + $1.amount }

            if monthSpending >= minimumMonthlySpending {
                totalSpending += monthSpending
                validMonths += 1
            }
        }

        guard validMonths >= minimumValidMonths else {
            return nil
        }

        return totalSpending / Decimal(validMonths)
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
