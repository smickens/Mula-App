//
//  DataManager+DataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/28/26.
//

import Foundation

extension DataManager {

    // MARK: Accounts

    /// Loads accounts from the active data source.
    func loadAccounts() {
        Task {
            do {
                accounts = try await dataSource.loadAccounts()
            } catch {
                print("❌ Error loading accounts: \(error.localizedDescription)")
            }
        }
    }

    /// Adds a new account to the active data source.
    func addAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.addAccount(account)
                accounts.append(account)
            } catch {
                print("❌ Error adding account: \(error.localizedDescription)")
            }
        }
    }

    /// Updates an existing account in the active data source.
    func updateAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.updateAccount(account)
                if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                    accounts[index] = account
                }
            } catch {
                print("❌ Error updating account: \(error.localizedDescription)")
            }
        }
    }

    /// Deletes an account from the active data source.
    func deleteAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.deleteAccount(account)
                accounts.removeAll { $0.id == account.id }
            } catch {
                print("❌ Error deleting account: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Transactions

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

    // MARK: Import Batches

    func importTransactions(_ transactions: [Transaction], fileName: String? = nil) {
        let batch = ImportBatch(name: fileName)

        Task {
            do {
                var importedTransactions: [Transaction] = []

                for var transaction in transactions {
                    transaction.importBatchId = batch.id
                    try await dataSource.addTransaction(transaction)
                    importedTransactions.append(transaction)
                }

                try await dataSource.addImportBatch(batch)

                self.transactions.append(contentsOf: importedTransactions)
                importBatches.append(batch)

                print("✅ Imported \(transactions.count) transactions in batch \(batch.id) (\(fileName ?? "unnamed file"))")
            } catch {
                print("❌ Failed to import transactions: \(error.localizedDescription)")
            }
        }
    }

    /// Loads import batches from the active data source.
    func loadImportBatches() {
        Task {
            do {
                importBatches = try await dataSource.loadImportBatches()
            } catch {
                print("❌ Error loading import batches: \(error.localizedDescription)")
            }
        }
    }

    /// Adds a new import batch to the active data source.
    func addImportBatch(_ batch: ImportBatch) {
        Task {
            do {
                try await dataSource.addImportBatch(batch)
                importBatches.append(batch)
            } catch {
                print("❌ Error adding import batch: \(error.localizedDescription)")
            }
        }
    }
}
