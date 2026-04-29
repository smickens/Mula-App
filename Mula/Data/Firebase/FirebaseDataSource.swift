//
//  FirebaseDataSource.swift
//  Mula
//
//  Created by Shanti Mickens on 4/28/26.
//

import Foundation
import FirebaseDatabase

final class FirebaseDataSource: DataSource {
    private let accountRef: DatabaseReference
    private let importBatchRef: DatabaseReference
    private let transactionRef: DatabaseReference

    init(databaseReference: DatabaseReference = Database.database().reference()) {
        accountRef = databaseReference.child("account")
        importBatchRef = databaseReference.child("importBatch")
        transactionRef = databaseReference.child("transaction")
    }

    // MARK: Accounts

    func loadAccounts() async throws -> [Account] {
        let snapshot = try await getData(from: accountRef)

        guard let value = snapshot.value else {
            print("❌ No account data available")
            return []
        }

        guard let data = value as? [String: [String: Any]] else {
            print("❌ Account data has an unexpected shape")
            return []
        }

        var accounts: [Account] = []
        for (accountId, accountData) in data {
            guard let name = accountData["name"] as? String,
                  let typeString = accountData["type"] as? String,
                  let type = AccountType.get(from: typeString) else {
                print("⚠️ Skipping malformed account: \(accountData)")
                continue
            }

            accounts.append(
                Account(
                    id: UUID(uuidString: accountId) ?? UUID(),
                    name: name,
                    type: type
                )
            )
        }

        print("✅ Loaded \(accounts.count) accounts from Firebase.")
        return accounts
    }

    func addAccount(_ account: Account) async throws {
        let accountDictionary: [String: Any] = [
            "name": account.name,
            "type": account.type.rawValue
        ]

        try await setValue(accountDictionary, at: accountRef.child(account.id.uuidString))
        print("✅ Added new account \(account.name)")
    }

    func updateAccount(_ account: Account) async throws {
        let accountDictionary: [String: Any] = [
            "name": account.name,
            "type": account.type.rawValue
        ]

        try await updateChildValues(accountDictionary, at: accountRef.child(account.id.uuidString))
        print("✅ Updated account \(account.name)")
    }

    func deleteAccount(_ account: Account) async throws {
        try await removeValue(at: accountRef.child(account.id.uuidString))
        print("✅ Deleted account with id \(account.id) name \(account.name)")
    }

    // MARK: Transactions

    func loadTransactions() async throws -> [Transaction] {
        let snapshot = try await getData(from: transactionRef)

        guard let value = snapshot.value as? [String: [String: Any]] else {
            print("⚠️ No transaction data available")
            return []
        }

        var transactions: [Transaction] = []
        for (firebaseKey, firebaseData) in value {
            do {
                transactions.append(try Transaction.decode(from: firebaseData))
            } catch {
                print("❌ Failed to decode transaction \(firebaseKey): \(error)")
            }
        }

        print("✅ Loaded \(transactions.count) transactions from Firebase.")
        return transactions
    }

    func addTransaction(_ transaction: Transaction) async throws {
        let transactionData = try transaction.asDictionary()
        try await setValue(transactionData, at: transactionRef.child(transaction.firebaseKey))
        print("✅ Added new transaction \"\(transaction.title)\"")
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        let transactionData = try transaction.asDictionary()
        try await updateChildValues(transactionData, at: transactionRef.child(transaction.firebaseKey))
        print("✅ Transaction \(transaction.id) updated successfully")
    }

    func deleteTransaction(_ transaction: Transaction) async throws {
        try await removeValue(at: transactionRef.child(transaction.firebaseKey))
        print("✅ Deleted transaction with id \(transaction.id) name \(transaction.title)")
    }

    // MARK: Import Batches

    func loadImportBatches() async throws -> [ImportBatch] {
        let snapshot = try await getData(from: importBatchRef)

        guard let data = snapshot.value as? [String: [String: Any]] else {
            print("ℹ️ No import batch data found.")
            return []
        }

        var importBatches: [ImportBatch] = []
        for (firebaseKey, firebaseData) in data {
            guard let id = UUID(uuidString: firebaseKey),
                  let timestamp = firebaseData["date"] as? TimeInterval else {
                print("⚠️ Skipping malformed batch record.")
                continue
            }

            importBatches.append(
                ImportBatch(
                    id: id,
                    date: Date(timeIntervalSince1970: timestamp),
                    name: firebaseData["name"] as? String
                )
            )
        }

        print("✅ Loaded \(importBatches.count) import batches from Firebase.")
        return importBatches
    }

    func addImportBatch(_ batch: ImportBatch) async throws {
        let importBatchDictionary: [String: Any] = [
            "date": batch.date.timeIntervalSince1970,
            "name": batch.name ?? ""
        ]

        try await setValue(importBatchDictionary, at: importBatchRef.child(batch.firebaseKey))
        print("✅ Added new import batch: \(String(describing: batch.name))")
    }

    // MARK: Helper Methods

    private func getData(from reference: DatabaseReference) async throws -> DataSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            reference.getData { error, snapshot in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot else {
                    continuation.resume(returning: DataSnapshot())
                    return
                }

                continuation.resume(returning: snapshot)
            }
        }
    }

    private func setValue(_ value: Any, at reference: DatabaseReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.setValue(value) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func updateChildValues(_ values: [AnyHashable: Any], at reference: DatabaseReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.updateChildValues(values) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func removeValue(at reference: DatabaseReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.removeValue { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
