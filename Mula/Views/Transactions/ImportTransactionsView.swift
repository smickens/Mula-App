//
//  UploadFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/24.
//

import SwiftUI

struct ImportTransactionsView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @Binding var importName: String
    @Binding var fileContent: String
    @State private var newTransactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
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

            HStack {
                newTransactionsList

                Divider()

                if let selectedTransaction = selectedTransaction, let index = newTransactions.firstIndex(where: { $0.id == selectedTransaction.id }) {
                    TransactionFormView(transaction: $newTransactions[index])
                } else {
                    emptyDetailView
                }
            }
        }
        .frame(width: 650, height: 340)
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
        .onAppear {
            newTransactions = ImportProcessor.processFileContentIntoTransactions(fileContent)
            selectedTransaction = newTransactions.first
        }
    }

    private var newTransactionsList: some View {
        List(selection: $selectedTransaction) {
            ForEach(newTransactions) { transaction in
                TransactionView(selectedTransaction: $selectedTransaction, swipeActionsEnabled: false, transaction: transaction)
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
