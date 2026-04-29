//
//  DataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/7/26.
//


protocol DataSource: AnyObject {

    // Accounts
    func loadAccounts() async throws -> [Account]
    func addAccount(_ account: Account) async throws
    func updateAccount(_ account: Account) async throws
    func deleteAccount(_ account: Account) async throws

    // Transactions
    func loadTransactions() async throws -> [Transaction]
    func addTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(_ transaction: Transaction) async throws

    // Import Batches
    func loadImportBatches() async throws -> [ImportBatch]
    func addImportBatch(_ batch: ImportBatch) async throws
}
