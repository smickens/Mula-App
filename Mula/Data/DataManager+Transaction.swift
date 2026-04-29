//
//  DataManager+Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import Foundation

extension DataManager {

    /// Loads transactions from the active data source.
    func loadTransactions() {
        Task {
            do {
                transactions = try await dataSource.loadTransactions()
            } catch {
                print("❌ Error loading transactions: \(error.localizedDescription)")
            }
        }
    }

    /// Adds a new transaction to the active data source.
    func addTransaction(_ transaction: Transaction) {
        Task {
            do {
                try await dataSource.addTransaction(transaction)
                transactions.append(transaction)
            } catch {
                print("❌ Failed to add transaction: \(error.localizedDescription)")
            }
        }
    }

    // TODO: create a bulk operation add

    /// Updates an existing transaction in the active data source.
    func updateTransaction(_ transaction: Transaction) {
        Task {
            do {
                try await dataSource.updateTransaction(transaction)
                if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                    transactions[index] = transaction
                }
            } catch {
                print("❌ Failed to update transaction: \(error.localizedDescription)")
            }
        }
    }

    /// Deletes a transaction from the active data source.
    func deleteTransaction(_ transaction: Transaction) {
        Task {
            do {
                try await dataSource.deleteTransaction(transaction)
                transactions.removeAll { $0.id == transaction.id }
            } catch {
                print("❌ Error deleting transaction: \(error.localizedDescription)")
            }
        }
    }
}
