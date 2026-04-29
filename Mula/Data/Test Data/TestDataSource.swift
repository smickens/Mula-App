//
//  TestDataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/28/26.
//

import Foundation

final class TestDataSource: DataSource {
    private var accounts: [Account]
    private var importBatches: [ImportBatch]
    private var transactions: [Transaction]

    init(testData: TestData.Type = TestData.self) {
        accounts = testData.accounts
        importBatches = testData.importBatches
        transactions = testData.transactions
    }

    // MARK: Accounts

    func loadAccounts() async throws -> [Account] {
        accounts
    }

    func addAccount(_ account: Account) async throws {
        accounts.append(account)
    }

    func updateAccount(_ account: Account) async throws {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index] = account
    }

    func deleteAccount(_ account: Account) async throws {
        accounts.removeAll { $0.id == account.id }
    }

    // MARK: Transactions

    func loadTransactions() async throws -> [Transaction] {
        transactions
    }

    func addTransaction(_ transaction: Transaction) async throws {
        transactions.append(transaction)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func deleteTransaction(_ transaction: Transaction) async throws {
        transactions.removeAll { $0.id == transaction.id }
    }

    // MARK: Import Batches

    func loadImportBatches() async throws -> [ImportBatch] {
        importBatches
    }

    func addImportBatch(_ batch: ImportBatch) async throws {
        importBatches.append(batch)
    }
}
