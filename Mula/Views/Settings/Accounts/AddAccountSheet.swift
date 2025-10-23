//
//  AddAccountSheet.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//


import SwiftUI

struct AddAccountSheet: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State private var newAccount = Account(id: UUID(), name: "", type: .saving)

    var body: some View {
        AccountFormView(
            account: $newAccount,
            title: "Add New Account",
            onSave: {
                dataManager.addAccount(newAccount)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}

