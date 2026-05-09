//
//  UploadFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/24.
//

import SwiftUI

// TODO: add deleting whole import batch and associated expenses (with confirmation)

// TODO: fix bug - deletea transaction in import popup view and it loses most of its height

struct ImportTransactionsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @Binding var importName: String
    @Binding var fileContent: String
    @State private var newTransactions: [Transaction] = []
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
                .disabled(newTransactions.isEmpty || importName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: processImportFile)
    }

    private var newTransactionsList: some View {
        List(selection: $selectedTransactionID) {
            ForEach(newTransactions) { transaction in
                TransactionView(selectedTransactionID: $selectedTransactionID, swipeActionsEnabled: false, transaction: transaction, displayingAccountId: nil)
                    .tag(transaction.id)
            }
            .onDelete { indexSet in
                newTransactions.remove(atOffsets: indexSet)
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
            selectedTransactionID = newTransactions.first?.id
            importErrorMessage = nil
        } catch {
            newTransactions = []
            selectedTransactionID = nil
            importErrorMessage = error.localizedDescription
        }
    }

    private func saveNewExpenses() {
        if !newTransactions.isEmpty {
            let trimmedName = importName.trimmingCharacters(in: .whitespaces)
            dataManager.importTransactions(newTransactions, fileName: trimmedName)
        }

        dismiss()
    }

    private func clearAllNewExpenses() {
        newTransactions = []

        dismiss()
    }
}
