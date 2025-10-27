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

    // MARK: Helper functions

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
