//
//  DataManager+ImportBatch.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation
import FirebaseDatabase

extension DataManager {

    func importTransactions(_ transactions: [Transaction], fileName: String? = nil) {
        let batch = ImportBatch(name: fileName)

        for var transaction in transactions {
            transaction.importBatchId = batch.id
            addTransaction(transaction)
        }

        addImportBatch(batch)

        print("✅ Imported \(transactions.count) transactions in batch \(batch.id) (\(fileName ?? "unnamed file"))")
    }

    /// Loads ImportBatches from Firebase.
    func loadImportBatches() {
        var loadedBatches: [ImportBatch] = []

        importBatchRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error {
                print("❌ Error loading import batches: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.value as? [String: [String: Any]] else {
                print("ℹ️ No import batch data found.")
                return
            }

            for (firebaseKey, firebaseData) in data {
                guard let id = UUID(uuidString: firebaseKey),
                      let timestamp = firebaseData["date"] as? TimeInterval else {
                    print("⚠️ Skipping malformed batch record.")
                    continue
                }

                let batch = ImportBatch(
                    id: id,
                    date: Date(timeIntervalSince1970: timestamp),
                    name: firebaseData["name"] as? String
                )
                loadedBatches.append(batch)
            }

            self.importBatches = loadedBatches

            print("✅ Loaded \(loadedBatches.count) import batches from Firebase.")
        }
    }

    /// Adds a new ImportBatch to Firebase.
    func addImportBatch(_ batch: ImportBatch) {
        let importBatchDictionary: [String: Any] = [
            "date": batch.date.timeIntervalSince1970,
            "name": batch.name ?? ""
        ]

        importBatchRef.child(batch.firebaseKey).setValue(importBatchDictionary) { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error adding import batch: \(error.localizedDescription)")
            } else {
                self.importBatches.append(batch)
                print("✅ Added new import batch: \(String(describing: batch.name))")
            }
        }
    }
}
