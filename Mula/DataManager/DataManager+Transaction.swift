//
//  DataManager+Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import Foundation
import FirebaseDatabase

extension DataManager {

    /// Loads transactions from Firebase
    func loadTransactions() {
        transactionRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error {
                print("❌ Error getting transactions: \(error.localizedDescription)")
                return
            }

            guard let value = snapshot?.value as? [String: [String: Any]] else {
                print("⚠️ No transaction data available")
                return
            }

            for (id, data) in value {
                guard let title = data["title"] as? String,
                      let amount = data["amount"] as? Double,
                      let dateTimestamp = data["date"] as? TimeInterval,
                      let categoryString = data["category"] as? String,
                      let category = TransactionCategory(rawValue: categoryString)
                else {
                    print("⚠️ Skipping invalid transaction: \(id)")
                    continue
                }

                let transaction = Transaction(
                    id: UUID(uuidString: id) ?? UUID(),
                    accountId: (data["accountId"] as? String).flatMap(UUID.init(uuidString:)),
                    importBatchId: (data["importBatchId"] as? String).flatMap(UUID.init(uuidString:)),
                    title: title,
                    date: Date(timeIntervalSince1970: dateTimestamp),
                    amount: amount,
                    category: category
                )

                self.transactions.append(transaction)
            }

            print("✅ Loaded \(transactions.count) transactions from Firebase.")
        }
    }

    /// Adds a new transaction to Firebase
    func addTransaction(_ transaction: Transaction) {
        let transactionDictionary: [String: Any] = [
            "title": transaction.title,
            "amount": transaction.amount,
            "date": transaction.date.timeIntervalSince1970,
            "category": transaction.category.rawValue,
            "accountId": transaction.accountId?.uuidString as Any,
            "importBatchId": transaction.importBatchId?.uuidString as Any
        ]

        transactionRef.child(transaction.id.uuidString).setValue(transactionDictionary)
    }

    /// Updates an existing transaction in Firebase
    func updateTransaction(_ transaction: Transaction) {
        let transactionDictionary: [String: Any] = [
            "title": transaction.title,
            "amount": transaction.amount,
            "date": transaction.date.timeIntervalSince1970,
            "category": transaction.category.rawValue,
            "accountId": transaction.accountId?.uuidString as Any,
            "importBatchId": transaction.importBatchId?.uuidString as Any
        ]

        transactionRef.child(transaction.id.uuidString).updateChildValues(transactionDictionary) { [weak self] error, _ in
            if let error = error {
                print("❌ Failed to update transaction: \(error.localizedDescription)")
            }

            guard let self = self else { return }

            print("✅ Transaction \(transaction.id) updated successfully")

            // Update locally so UI reflects the change immediately
            if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
                self.transactions[index] = transaction
            }
        }
    }

    /// Deletes a transaction from Firebase
    func deleteTransaction(_ transaction: Transaction) {
        transactionRef.child(transaction.id.uuidString).removeValue { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error deleting transaction: \(error.localizedDescription)")
            } else if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
                self.accounts.remove(at: index)
                print("✅ Deleted transaction with id \(transaction.id) name \(transaction.title)")
            }
        }
    }
}

// MARK: - Temporary Migration

extension DataManager {

    func mapCategoryToTransactionCategory(_ category: Category) -> TransactionCategory {
        switch category {
        case .housing:
            return .housing
        case .eatingOut:
            return .eatingOut
        case .groceries:
            return .groceries
        case .shopping:
            return .shopping
        case .transportation:
            return .transit
        case .entertainment:
            return .entertainment
        case .job:
            return .income
        case .retirement:
            return .transfer
        case .stocks:
            return .transfer
        case .misc:
            return .other
        }
    }

    func migrateExpensesToTransactions() async {
        let sourceRef = expenseRef
        let targetRef = transactionRef

        do {
            let snapshot = try await sourceRef.getData()

            guard let value = snapshot.value as? [String: [String: Any]] else {
                print("⚠️ No expense data found or invalid format.")
                return
            }

            print("🔄 Starting migration of \(value.count) expenses...")

            for (expenseId, expenseData) in value {
                guard
                    let title = expenseData["title"] as? String,
                    let dateInterval = expenseData["date"] as? TimeInterval,
                    let amount = expenseData["amount"] as? Double,
                    let categoryString = expenseData["category"] as? String
                else {
                    print("⚠️ Skipping expense \(expenseId) due to missing data.")
                    continue
                }

                let category: Category = Category.init(rawValue: categoryString) ?? .misc

                let transactionCategory = mapCategoryToTransactionCategory(category)

                let transaction: [String: Any] = [
                    "accountId": "781259EA-A78D-431A-B697-3EC87A9183D2",
                    "title": title,
                    "date": dateInterval,
                    "amount": amount,
                    "category": transactionCategory.rawValue
                ]

                try await targetRef.child(expenseId).setValue(transaction)
            }

            print("✅ Migration complete! All expenses copied to /transaction.")
        } catch {
            print("❌ Error during migration: \(error.localizedDescription)")
        }
    }
}
