//
//  EditAccountSheet.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//


import SwiftUI

struct EditAccountSheet: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State var account: Account

    var body: some View {
        AccountFormView(
            account: $account,
            title: "Edit Account",
            onSave: {
                dataManager.updateAccount(account)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}
