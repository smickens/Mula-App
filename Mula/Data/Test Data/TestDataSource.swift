//
//  TestDataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/28/26.
//

import Foundation

final class TestDataSource: DataSource {
    private var accounts: [Account]
    private var accountStatements: [AccountStatement]
    private var importBatches: [ImportBatch]
    private var transactions: [Transaction]

    init(testData: TestData.Type = TestData.self) {
        accounts = testData.accounts
        accountStatements = testData.accountStatements
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

    func addTransactions(_ transactions: [Transaction]) async throws {
        self.transactions.append(contentsOf: transactions)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func deleteTransaction(_ transaction: Transaction) async throws {
        transactions.removeAll { $0.id == transaction.id }
    }

    // MARK: Account Statements

    func loadAccountStatements() async throws -> [AccountStatement] {
        accountStatements
    }

    func addAccountStatement(_ statement: AccountStatement) async throws {
        accountStatements.append(statement)
    }

    // MARK: Import Batches

    func loadImportBatches() async throws -> [ImportBatch] {
        importBatches
    }

    func addImportBatch(_ batch: ImportBatch) async throws {
        importBatches.append(batch)
    }

    func deleteImportBatch(_ batch: ImportBatch, transactions: [Transaction]) async throws {
        importBatches.removeAll { $0.id == batch.id }
        self.transactions.removeAll { transaction in
            transactions.contains { $0.id == transaction.id }
        }
    }
}
