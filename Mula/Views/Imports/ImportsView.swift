//
//  ImportsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct ImportsView: View {
    @Environment(DataManager.self) private var dataManager

    @State private var selectedImportBatch: ImportBatch?
    @State private var selectedTransactionID: UUID?

    @State private var showingImportTransactionsForm: Bool = false
    @State private var fileContent: String = ""
    @State private var fileName: String = ""

    var body: some View {
        HStack(spacing: 0) {
            importBatchesList

            Divider()

            if let selectedImportBatch = selectedImportBatch {
                transactionsAndDetailView(for: selectedImportBatch)
            } else {
                emptyImportView
            }
        }
        .navigationTitle("Imports")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    importTransactionsCSVFile()
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showingImportTransactionsForm) {
            ImportTransactionsView(importName: $fileName, fileContent: $fileContent)
        }
    }

    private func importTransactionsCSVFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.commaSeparatedText]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false

        if openPanel.runModal() == .OK,
           let fileURL = openPanel.url,
           let data = try? Data(contentsOf: fileURL),
           let content = String(data: data, encoding: .utf8) {
            fileContent = content
            fileName = fileURL.lastPathComponent // <-- Capture the file name
            print("✅ Imported transactions from file (\(fileName)) for processing")

            showingImportTransactionsForm.toggle()
        } else {
            print("❌ Failed to import transactions from file to process")
        }
    }

    // MARK: - Import Batches List

    private var importBatchesList: some View {
        List(selection: $selectedImportBatch) {
            ForEach(dataManager.importBatches) { batch in
                ImportBatchRow(batch: batch)
                    .tag(batch)
            }
        }
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
    }

    // MARK: - Transactions and Detail View

    private func transactionsAndDetailView(for batch: ImportBatch) -> some View {
        let transactions = dataManager.transactions
            .filter { $0.importBatchId == batch.id }
            .sorted { $0.date < $1.date }

        return HStack(spacing: 0) {
            // Middle: Transactions List
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(batch.name ?? "Untitled Import")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(batch.date, format: .dateTime.month().day().year())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(transactions.count) transaction\(transactions.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

                // Transactions List
                List(selection: $selectedTransactionID) {
                    ForEach(transactions) { transaction in
                        TransactionView(
                            selectedTransactionID: $selectedTransactionID,
                            swipeActionsEnabled: true,
                            transaction: transaction,
                            displayingAccountId: nil
                        )
                        .tag(transaction.id)
                    }
                }
            }
            .frame(idealWidth: 400, maxWidth: 500)

            Divider()

            // Right: Transaction Detail
            if let selectedTransactionID,
               let selectedTransaction = transactions.first(where: { $0.id == selectedTransactionID }) {
                TransactionDetailView(transaction: selectedTransaction, displayingAccountId: nil)
            } else {
                emptyTransactionView
            }
        }
    }

    // MARK: - Empty States

    private var emptyImportView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Import Selected")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Select an import batch to view its transactions")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTransactionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Transaction Selected")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Select a transaction to view its details")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func accountName(for accountId: UUID?) -> String {
        guard let accountId = accountId,
              let account = dataManager.accounts.first(where: { $0.id == accountId }) else {
            return "Unknown"
        }
        return account.name
    }
}

// MARK: - Supporting Views

struct ImportBatchRow: View {
    let batch: ImportBatch

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(batch.name ?? "Untitled Import")
                .font(.headline)

            Text(batch.date, format: .dateTime.month().day().year())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
