//
//  EditTransactionFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import SwiftUI

struct EditTransactionFormView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State var transaction: Transaction

    var body: some View {
        TransactionFormView(
            transaction: $transaction,
            title: "Edit Transaction",
            onSave: {
                dataManager.updateTransaction(transaction)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}
