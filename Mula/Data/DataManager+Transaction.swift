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
        transactions.removeAll()

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

            for (firebaseKey, firebaseData) in value {
                guard let title = firebaseData["title"] as? String,
                      let amount = firebaseData["amount"] as? Double,
                      let dateTimestamp = firebaseData["date"] as? TimeInterval,
                      let categoryString = firebaseData["category"] as? String,
                      let category = TransactionCategory(rawValue: categoryString),
                      let typeString = firebaseData["type"] as? String,
                      let type = TransactionType(rawValue: typeString)
                else {
                    print("⚠️ Skipping invalid transaction: \(firebaseKey)")
                    continue
                }

                let accountIdString = (firebaseData["accountId"] as? String).flatMap(UUID.init(uuidString:))
                let destinationAccountIdString = (firebaseData["destinationAccountId"] as? String).flatMap(UUID.init(uuidString:))
                let importBatchIdString = (firebaseData["importBatchId"] as? String).flatMap(UUID.init(uuidString:))

                let transaction = Transaction(
                    id: UUID(uuidString: firebaseKey) ?? UUID(),
                    accountId: accountIdString,
                    destinationAccountId: destinationAccountIdString,
                    importBatchId: importBatchIdString,
                    title: title,
                    date: Date(timeIntervalSince1970: dateTimestamp),
                    amount: abs(amount),
                    category: category,
                    type: type
                )

                self.transactions.append(transaction)
            }

            print("✅ Loaded \(transactions.count) transactions from Firebase.")
        }
    }

    /// Adds a new transaction to Firebase
    func addTransaction(_ transaction: Transaction) {
        transactionRef.child(transaction.firebaseKey).setValue(transaction.asDictionary) { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error adding transaction: \(error.localizedDescription)")
            } else {
                self.transactions.append(transaction)
                print("✅ Added new transaction \(transaction.title)")
            }
        }
    }

    // TODO: create a bulk operation add

    /// Updates an existing transaction in Firebase
    func updateTransaction(_ transaction: Transaction) {
        transactionRef.child(transaction.firebaseKey).updateChildValues(transaction.asDictionary) { [weak self] error, _ in
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
        transactionRef.child(transaction.firebaseKey).removeValue { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error deleting transaction: \(error.localizedDescription)")
            } else if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
                self.transactions.remove(at: index)
                print("✅ Deleted transaction with id \(transaction.id) name \(transaction.title)")
            }
        }
    }
}
