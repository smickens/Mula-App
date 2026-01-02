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
        accountId: NewTransactionFormView.defaultAccountId,
        importBatchId: nil,
        title: "",
        date: Date(),
        amount: 0.0,
        category: .other,
        type: .expense
    )

    var body: some View {
        TransactionFormView(
            transaction: $newTransaction,
            title: "New Item",
            onSave: {
                dataManager.addTransaction(newTransaction)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
        .frame(width: 360)
    }

    static private let defaultAccountId = UUID(uuidString: "781259EA-A78D-431A-B697-3EC87A9183D2")
}
