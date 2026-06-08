//
//  DataManager+DataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/28/26.
//

import Foundation
import MulaCore

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
        Task {
            do {
                let batch = makeImportBatch(named: fileName)
                try await importTransactions(transactions, batch: batch)

                if let batch {
                    try await dataSource.addImportBatch(batch)
                    importBatches.insert(batch, at: 0)
                }

                print("✅ Imported \(transactions.count) transactions\(batch.map { " in batch \($0.id)" } ?? "") (\(fileName ?? "unnamed file"))")
            } catch {
                print("❌ Failed to import transactions: \(error.localizedDescription)")
            }
        }
    }

    func importAccountStatements(_ accountStatements: [AccountStatement], fileName: String? = nil) {
        Task {
            do {
                let batch = makeImportBatch(named: fileName)
                try await importAccountStatements(accountStatements, batch: batch)

                if let batch {
                    try await dataSource.addImportBatch(batch)
                    importBatches.insert(batch, at: 0)
                }

                print("✅ Imported \(accountStatements.count) account statements\(batch.map { " in batch \($0.id)" } ?? "") (\(fileName ?? "unnamed file"))")
            } catch {
                print("❌ Failed to import account statements: \(error.localizedDescription)")
            }
        }
    }

    func importParsedFileContents(
        transactions: [Transaction],
        accountStatements: [AccountStatement],
        fileName: String? = nil
    ) {
        Task {
            do {
                let batch = makeImportBatch(named: fileName)

                try await importTransactions(transactions, batch: batch)
                try await importAccountStatements(accountStatements, batch: batch)

                if let batch {
                    try await dataSource.addImportBatch(batch)
                    importBatches.insert(batch, at: 0)
                }

                print("✅ Imported \(transactions.count) transactions and \(accountStatements.count) account statements\(batch.map { " in batch \($0.id)" } ?? "") (\(fileName ?? "unnamed file"))")
            } catch {
                print("❌ Failed to import parsed file contents: \(error.localizedDescription)")
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

    func deleteImportBatch(_ batch: ImportBatch) {
        let batchTransactions = transactions.filter { $0.importBatchId == batch.id }
        let batchStatements = accountStatements.filter { $0.importBatchId == batch.id }

        Task {
            do {
                try await dataSource.deleteImportBatch(batch, transactions: batchTransactions, accountStatements: batchStatements)
                transactions.removeAll { $0.importBatchId == batch.id }
                accountStatements.removeAll { $0.importBatchId == batch.id }
                importBatches.removeAll { $0.id == batch.id }
                
            } catch {
                print("❌ Error deleting import batch: \(error.localizedDescription)")
            }
        }
    }

    private func makeImportBatch(named fileName: String?) -> ImportBatch? {
        let trimmedName = fileName?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedName, !trimmedName.isEmpty else {
            return nil
        }

        return ImportBatch(name: trimmedName)
    }

    private func importTransactions(_ transactions: [Transaction], batch: ImportBatch?) async throws {
        let importedTransactions = transactions.map { transaction in
            guard let batch else { return transaction }
            return transaction.withImportBatchId(batch.id)
        }

        try await dataSource.addTransactions(importedTransactions)
        self.transactions.append(contentsOf: importedTransactions)
    }

    private func importAccountStatements(_ accountStatements: [AccountStatement], batch: ImportBatch?) async throws {
        let importedStatements = accountStatements.map { statement in
            guard let batch else { return statement }
            return statement.withImportBatchId(batch.id)
        }

        for statement in importedStatements {
            try await dataSource.addAccountStatement(statement)
        }

        self.accountStatements.append(contentsOf: importedStatements)
    }
}
