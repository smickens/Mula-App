//
//  NewTransactionFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import SwiftUI

struct NewTransactionFormView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State private var newTransaction = Transaction(
        id: UUID(),
        accountId: nil,
        importBatchId: nil,
        title: "",
        date: Date(),
        amount: 0.0,
        category: .other
    )

    var body: some View {
        TransactionFormView(
            transaction: $newTransaction,
            title: "New Transaction",
            onSave: {
                dataManager.addTransaction(newTransaction)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}
