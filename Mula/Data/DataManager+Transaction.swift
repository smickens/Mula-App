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

            // TODO: may change to storing amount as a string in firebase
//            let amount = Decimal(string: firebaseData["amount"] as? String ?? "") ?? 0

            for (firebaseKey, firebaseData) in value {
                do {
                    let transaction = try Transaction.decode(from: firebaseData)

                    self.transactions.append(transaction)
                } catch {
                    print("❌ Failed to decode transaction \(firebaseKey): \(error)")
                }
            }

            print("✅ Loaded \(transactions.count) transactions from Firebase.")

//            // TEMP: update transactions to have a type
//            for transaction in transactions {
//                updateTransaction(transaction)
//            }
////
//            print("✅ Done updating transactions")
        }
    }

    /// Adds a new transaction to Firebase
    func addTransaction(_ transaction: Transaction) {
        do {
            let transactionData = try transaction.asDictionary()

            transactionRef.child(transaction.firebaseKey).setValue(transactionData) { [weak self] error, _ in
                guard let self = self else { return }

                if let error {
                    print("❌ Error adding transaction: \(error.localizedDescription)")
                } else {
                    self.transactions.append(transaction)
                    print("✅ Added new transaction \"\(transaction.title)\"")
                }
            }
        } catch {
            print("❌ Failed to add transaction: \(error.localizedDescription)")
        }
    }

    // TODO: create a bulk operation add

    /// Updates an existing transaction in Firebase
    func updateTransaction(_ transaction: Transaction) {
        guard let transactionData = try? transaction.asDictionary() else {
            print("❌ Failed to update transaction")
            return
        }

        transactionRef.child(transaction.firebaseKey).updateChildValues(transactionData) { [weak self] error, _ in
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
