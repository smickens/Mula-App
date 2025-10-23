//
//  AccountsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import SwiftUI

struct AccountsView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var showingAddSheet = false
    @State private var selectedAccount: Account?
    @State private var selectedAccountForEdit: Account? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Accounts")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Account", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.top, .horizontal])

            List(selection: $selectedAccount) {
                ForEach(dataManager.accounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            Text(account.type.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            selectedAccountForEdit = account
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            dataManager.deleteAccount(account)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .listStyle(.inset)
            .padding([.horizontal, .bottom])
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAccountSheet()
        }
        .sheet(item: $selectedAccountForEdit) { account in
            EditAccountSheet(account: account)
        }
    }
}
