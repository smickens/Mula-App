//
//  TransactionFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import SwiftUI

struct TransactionFormView: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var transaction: Transaction
    let title: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)

            // Form Fields
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $transaction.title)
                    .textFieldStyle(.roundedBorder)

                TextField("Amount", value: $transaction.amount, format: .currency(code: "USD"))
                    .textFieldStyle(.roundedBorder)

                Picker("Account", selection: Binding(
                    get: {
                        dataManager.accounts.first(where: { $0.id == transaction.accountId })
                    },
                    set: { selected in
                        transaction.accountId = selected?.id
                    })
                ) {
                    Text("Select Account")
                        .tag(Optional<Account>.none)
                    ForEach(dataManager.accounts, id: \.id) { account in
                        Text(account.name)
                            .tag(Optional(account))
                    }
                }
                .pickerStyle(.menu)

                Picker("Category", selection: $transaction.category) {
                    ForEach(TransactionCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                    }
                }
                .pickerStyle(.menu)

                DatePicker("Date", selection: $transaction.date, in: ...Date(), displayedComponents: .date)
            }

            // Action Buttons
            HStack {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.gray)

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isFormValid)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 380)
    }

    private var isFormValid: Bool {
        !transaction.title.trimmingCharacters(in: .whitespaces).isEmpty && transaction.amount != 0
    }
}
