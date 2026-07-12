//
//  ImportsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI
import MulaCore

struct ImportsView: View {
    @Environment(DataManager.self) private var dataManager

    @State private var selectedImportBatch: ImportBatch?
    @State private var selectedTransactionID: UUID?
    @State private var selectedCategoryId: String?

    @State private var showingImportTransactionsForm = false
    @State private var isShowingDeleteConfirmation = false
    @State private var importBatchPendingDeletion: ImportBatch?
    @State private var fileContent = ""
    @State private var fileName = ""

    private let cornerRadius: CGFloat = 12
    private let panePadding: CGFloat = 12
    private let gridSpacing: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            HStack(alignment: .top, spacing: gridSpacing) {
                importBatchesList
                    .frame(maxWidth: .infinity)

                if let selectedImportBatch {
                    transactionsListView(for: selectedImportBatch)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    emptyImportView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .navigationTitle("Imports")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    importTransactionsCSVFile()
                } label: {
                    Label("Import CSV", systemImage: "square.and.arrow.down")
                }
            }
        }
        .onAppear {
            selectMostRecentImportIfNeeded()
        }
        .onChange(of: dataManager.importBatches) { _, _ in
            if let selectedImportBatch,
               dataManager.importBatches.contains(where: { $0.id == selectedImportBatch.id }) {
                return
            }

            selectMostRecentImportIfNeeded()
        }
        .onChange(of: selectedImportBatch) { _, _ in
            selectedTransactionID = nil
            selectedCategoryId = nil
        }
        .confirmationDialog(
            "Delete Import?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Import and Transactions", role: .destructive) {
                if let importBatchPendingDeletion {
                    deleteImportBatch(importBatchPendingDeletion)
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            let transactionsCount = importBatchPendingDeletion.map { transactions(for: $0).count } ?? 0
            let importName = importBatchPendingDeletion?.name ?? "this import"
            Text("This will permanently delete \(importName) and \(transactionsCount) associated transaction\(transactionsCount == 1 ? "" : "s").")
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
        openPanel.directoryURL = URL(fileURLWithPath: "/Users/shantimickens/Library/Mobile Documents/com~apple~CloudDocs/docs/expenses : transactions")

        if openPanel.runModal() == .OK,
           let fileURL = openPanel.url,
           let data = try? Data(contentsOf: fileURL),
           let content = String(data: data, encoding: .utf8) {
            fileContent = content
            fileName = fileURL.lastPathComponent
            print("✅ Imported transactions from file (\(fileName)) for processing")

            showingImportTransactionsForm.toggle()
        } else {
            print("❌ Failed to get contents of file to import transactions from")
        }
    }

    // MARK: - Import Batches

    private var importBatchesList: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(selection: $selectedImportBatch) {
                ForEach(dataManager.importBatches) { batch in
                    ImportBatchSelectionRow(
                        batch: batch,
                        isSelected: selectedImportBatch?.id == batch.id
                    )
                    .tag(batch)
                    .swipeActions {
                        Button(role: .destructive) {
                            importBatchPendingDeletion = batch
                            isShowingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding(panePadding)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(cornerRadius)
        .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Transactions

    private func transactionsListView(for batch: ImportBatch) -> some View {
        let batchTransactions = transactions(for: batch)
        let filteredTransactions = filteredTransactions(for: batchTransactions)

        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(batch.name ?? "Untitled Import")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(headerSubtitle(transactionCount: filteredTransactions.count))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    categoryFilterMenu(for: batchTransactions)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if filteredTransactions.isEmpty {
                emptyTransactionsListView
            } else {
                List(selection: $selectedTransactionID) {
                    ForEach(filteredTransactions) { transaction in
                        TransactionView(
                            selectedTransactionID: $selectedTransactionID,
                            swipeActionsEnabled: true,
                            transaction: transaction,
                            configuration: .standard
                        )
                        .tag(transaction.id)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(cornerRadius)
    }

    private func filteredTransactions(for transactions: [Transaction]) -> [Transaction] {
        guard let selectedCategoryId else {
            return transactions
        }

        return transactions.filter { $0.category.id == selectedCategoryId }
    }

    private func categoryFilterMenu(for transactions: [Transaction]) -> some View {
        let categoryOptions = categoryOptions(for: transactions)

        return Menu {
            Button("All Categories") {
                selectedCategoryId = nil
            }

            if !categoryOptions.isEmpty {
                Divider()

                ForEach(categoryOptions, id: \.id) { category in
                    Button(category.displayName) {
                        selectedCategoryId = category.id
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedCategoryName(for: categoryOptions))
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
            .frame(maxWidth: 180)
        }
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
    }

    private func categoryOptions(for transactions: [Transaction]) -> [any TransactionCategoryProtocol] {
        var seenIDs = Set<String>()
        var categories: [any TransactionCategoryProtocol] = []

        for transaction in transactions {
            let category = transaction.category
            if seenIDs.insert(category.id).inserted {
                categories.append(category)
            }
        }

        return categories.sorted { $0.displayName < $1.displayName }
    }

    private func selectedCategoryName(for categories: [any TransactionCategoryProtocol]) -> String {
        guard let selectedCategoryId,
              let category = categories.first(where: { $0.id == selectedCategoryId }) else {
            return "All Categories"
        }

        return category.displayName
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
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(cornerRadius)
    }

    private var emptyTransactionsListView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            Text(selectedCategoryId == nil ? "This import has no transactions" : "No transactions for this category")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Helpers

    private func transactions(for batch: ImportBatch) -> [Transaction] {
        dataManager.transactions
            .filter { $0.importBatchId == batch.id }
            .sorted { $0.date < $1.date }
    }

    private func headerSubtitle(transactionCount: Int) -> String {
        "\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")"
    }

    private func deleteImportBatch(_ batch: ImportBatch) {
        dataManager.deleteImportBatch(batch)

        if selectedImportBatch?.id == batch.id {
            selectedImportBatch = nil
        }

        selectedTransactionID = nil
        selectedCategoryId = nil
    }

    private func selectMostRecentImportIfNeeded() {
        guard selectedImportBatch == nil else { return }
        selectedImportBatch = dataManager.importBatches.first
    }
}

// MARK: - Supporting Views

private struct ImportBatchSelectionRow: View {
    let batch: ImportBatch
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(batch.name ?? "Untitled Import")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(batch.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}
