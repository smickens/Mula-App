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

    var body: some View {
        TransactionFormView(
            title: "New Item",
            onSave: { updatedTransaction in
                dataManager.addTransaction(updatedTransaction)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
        .frame(width: 360)
    }
}
