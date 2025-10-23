//
//  AccountFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//


import SwiftUI

struct AccountFormView: View {
    @Binding var account: Account
    let title: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)

            TextField("Account Name", text: $account.name)
                .textFieldStyle(.roundedBorder)

            Picker("Account Type", selection: $account.type) {
                ForEach(AccountType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
    }
}
