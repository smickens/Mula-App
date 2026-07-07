//
//  UploadFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/24.
//

import SwiftUI
import MulaCore

// TODO: fix bug - deletea transaction in import popup view and it loses most of its height

struct ImportTransactionsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @Binding var importName: String
    @Binding var fileContent: String
    @State private var newTransactions: [Transaction] = []
    @State private var newAccountStatements: [AccountStatement] = []
    @State private var selectedTransactionID: UUID?
    @State private var importErrorMessage: String?

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Import Transactions")
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Text("Import as:")
                        .foregroundColor(.secondary)

                    TextField("Import name", text: $importName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 12)

            Divider()

            if let importErrorMessage {
                importErrorView(message: importErrorMessage)
            } else {
                HStack {
                    newTransactionsList

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        accountStatementPreview

                        Divider()

                        if let selectedTransactionID,
                           let index = newTransactions.firstIndex(where: { $0.id == selectedTransactionID }) {
                            TransactionFormView(
                                transaction: newTransactions[index],
                                title: "",
                                onSave: { updatedTransaction in
                                    newTransactions[index] = updatedTransaction
                                }
                            )
                            .id(selectedTransactionID)
                        } else {
                            emptyDetailView
                        }
                    }
                }
            }
        }
        .frame(width: 800)
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button{
                    clearAllNewExpenses()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.red)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button{
                    saveNewExpenses()
                } label: {
                    Text("Import")
                }
                .disabled((newTransactions.isEmpty && newAccountStatements.isEmpty) || importName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: processImportFile)
    }

    private var newTransactionsList: some View {
        List(selection: $selectedTransactionID) {
            if newTransactions.isEmpty {
                Text("No transactions extracted")
                    .foregroundColor(.secondary)
                    .tag(UUID?.none)
            }

            ForEach(newTransactions) { transaction in
                TransactionView(
                    selectedTransactionID: $selectedTransactionID,
                    swipeActionsEnabled: false,
                    transaction: transaction,
                    configuration: .standard
                )
                    .tag(transaction.id)
            }
            .onDelete { indexSet in
                newTransactions.remove(atOffsets: indexSet)
            }
        }
    }

    private var accountStatementPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Balance Checkpoints")
                .font(.headline)

            Text("\(newAccountStatements.count) statement\(newAccountStatements.count == 1 ? "" : "s") will be imported")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if newAccountStatements.isEmpty {
                Text("No balances extracted")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(newAccountStatements) { statement in
                            HStack {
                                Text(Self.statementDateFormatter.string(from: statement.date))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(statement.balance.toCurrency())
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
    }

    private var emptyDetailView: some View {
        VStack {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Select a transaction to edit")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func importErrorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundColor(.orange)

            Text("Import failed")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func processImportFile() {
        do {
            let result = try ImportProcessor.processFileContent(fileContent)
            newTransactions = result.transactions
            newAccountStatements = result.accountStatements.sorted { $0.date > $1.date }
            selectedTransactionID = newTransactions.first?.id
            importErrorMessage = nil
        } catch {
            newTransactions = []
            newAccountStatements = []
            selectedTransactionID = nil
            importErrorMessage = error.localizedDescription
        }
    }

    private func saveNewExpenses() {
        if !newTransactions.isEmpty || !newAccountStatements.isEmpty {
            let trimmedName = importName.trimmingCharacters(in: .whitespaces)
            dataManager.importParsedFileContents(
                transactions: newTransactions,
                accountStatements: newAccountStatements,
                fileName: trimmedName
            )
        }

        dismiss()
    }

    private func clearAllNewExpenses() {
        newTransactions = []
        newAccountStatements = []

        dismiss()
    }

    private static let statementDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}
