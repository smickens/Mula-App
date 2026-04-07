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

    @State private var state: TransactionFormState
    @State private var errorMessage: String?

    let title: String?
    let onSave: (Transaction) -> Void
    let onCancel: (() -> Void)?

    init (
        initialState: TransactionFormState,
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
        self.onSave = onSave
        self.onCancel = onCancel
        _state = State(initialValue: initialState)
    }


    // New transaction
    init(
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.init(initialState: TransactionFormState(), title: title, onSave: onSave, onCancel: onCancel)
    }

    // Edit existing transaction
    init(
        transaction: Transaction,
        title: String? = nil,
        onSave: @escaping (Transaction) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.init(initialState: TransactionFormState(from: transaction), title: title, onSave: onSave, onCancel: onCancel)
    }

    var body: some View {
        VStack(spacing: 16) {

            // MARK: Form Title
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // MARK: Type Picker
            Picker("", selection: $state.type) {
                ForEach(TransactionKindType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)

            // MARK: Title
            TextField("Title", text: $state.title)
                .textFieldStyle(.roundedBorder)

            // MARK: Amount
            HStack(spacing: 0) {
                Text("$")
                    .foregroundColor(.secondary)
                    .padding(.leading, 6)

                TextField("Amount", text: $state.amountString)
                    .textFieldStyle(.roundedBorder)
                    .padding(6)
            }

            // MARK: Source Account
            Picker(state.type == .transfer ? "From" : "Account", selection: $state.sourceAccountId) {
                ForEach(dataManager.accounts) { account in
                    Text(account.name).tag(Optional(account.id))
                }
            }
            .pickerStyle(.menu)

            // MARK: Category Picker
            categoryPicker

            // MARK: Transfer Destination
            if state.type == .transfer {
                Picker("To", selection: $state.destinationAccountId) {
                    ForEach(dataManager.accounts) { account in
                        Text(account.name).tag(Optional(account.id))
                    }
                }
                .pickerStyle(.menu)
            }

            // MARK: Date
            DatePicker("Date",
                       selection: $state.date,
                       in: ...Date(),
                       displayedComponents: .date)

            // MARK: Error Message
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            // MARK: Buttons
            HStack {
                if let onCancel {
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                }

                Button("Save") {
                    do {
                        let transaction = try state.toTransaction()
                        onSave(transaction)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 12)
        }
        .padding(20)
    }

    // MARK: Category Picker ViewBuilder

    @ViewBuilder
    private var categoryPicker: some View {
        switch state.type {
        case .expense:
            Picker("Category", selection: $state.expenseCategory) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.menu)

        case .income:
            Picker("Category", selection: $state.incomeCategory) {
                ForEach(IncomeCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.menu)

        case .transfer:
            Picker("Category", selection: $state.transferCategory) {
                ForEach(TransferCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
