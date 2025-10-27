//
//  TransactionFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import SwiftUI

struct TransactionFormView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @Binding var transaction: Transaction

    @State private var amountString: String = ""

    let title: String?
    let onSave: (() -> Void)?
    let onCancel: (() -> Void)?

    init(
        transaction: Binding<Transaction>,
        title: String? = nil,
        onSave: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._transaction = transaction
        self.title = title
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
            }

            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $transaction.title)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 0) {
                    Text("$")
                        .padding(.leading, 6)
                        .foregroundColor(.secondary)

                    TextField("Amount", value: $transaction.amount, formatter: transactionAmountFormatter)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: amountString) { newValue, _ in
                            transaction.amount = Double(newValue) ?? 0.0
                        }
                        .padding(6)
                }

                Picker("Category", selection: $transaction.category) {
                    ForEach(TransactionCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                    }
                }
                .pickerStyle(.menu)

                Picker("Account", selection: Binding(
                    get: { transaction.accountId },
                    set: { transaction.accountId = $0 }
                )) {
                    ForEach(dataManager.accounts) { account in
                        Text(account.name)
                            .tag(account.id)
                    }
                }
                .pickerStyle(.menu)

                DatePicker("Date", selection: $transaction.date, in: ...Date(), displayedComponents: .date)
            }

            actionButtons
                .padding(.top, 12)
        }
        .padding(20)
    }

    @ViewBuilder
    private var actionButtons: some View {
        HStack {
            if let onCancel = onCancel {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                .padding(.trailing, 6)
                .buttonStyle(.bordered)
            }

            if let onSave = onSave {
                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                .keyboardShortcut(.defaultAction)
            }
        }
    }

    private var isFormValid: Bool {
        !transaction.title.trimmingCharacters(in: .whitespaces).isEmpty && transaction.amount != 0
    }

    private let transactionAmountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
        return formatter
    }()
}
