//
//  DataManager+ImportBatch.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

extension DataManager {

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
