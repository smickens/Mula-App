//
//  AccountsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct AccountsView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var selectedAccountId: UUID?
    @State private var selectedTransaction: Transaction?
    @State private var expandedSections: Set<AccountType> = Set(AccountType.allCases)

    // Special UUID to represent "All Accounts"
    private let allAccountsId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    var body: some View {
        HStack(spacing: 0) {
            // Left: Accounts List
            accountsList

            Divider()

            // Middle: Transactions List
            transactionsListView

            Divider()

            // Right: Transaction Detail
            if let selectedTransaction = selectedTransaction {
                TransactionDetailView(transaction: selectedTransaction)
            } else {
                emptyTransactionView
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // TODO: Action to add new account
                } label: {
                    Label("Add Account", systemImage: "plus")
                }
            }
        }
    }

    // MARK: - Accounts List

    private var accountsList: some View {
        List(selection: $selectedAccountId) {
            // All Accounts option
            Label("All Accounts", systemImage: "list.bullet")
                .tag(allAccountsId)

            // Accounts grouped by type with disclosure groups
            ForEach(AccountType.allCases) { accountType in
                let accountsOfType = dataManager.accounts.filter { $0.type == accountType }

                if !accountsOfType.isEmpty {
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSections.contains(accountType) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedSections.insert(accountType)
                                } else {
                                    expandedSections.remove(accountType)
                                }
                            }
                        )
                    ) {
                        ForEach(accountsOfType) { account in
                            AccountRow(account: account)
                                .tag(account.id)
                        }
                    } label: {
                        Label(accountType.displayName, systemImage: iconForAccountType(accountType))
                    }
                }
            }
        }
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .onAppear {
            // Select "All Accounts" by default
            if selectedAccountId == nil {
                selectedAccountId = allAccountsId
            }
        }
    }

    // MARK: - Transactions List

    private var transactionsListView: some View {
        let transactions = filteredTransactions

        return VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(headerTitle)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(transactions.count) transaction\(transactions.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if selectedAccountId != allAccountsId,
                   let selectedAccountId = selectedAccountId,
                   let account = dataManager.accounts.first(where: { $0.id == selectedAccountId }) {
                    Text(account.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Transactions List
            if transactions.isEmpty {
                emptyTransactionsListView
            } else {
                List(selection: $selectedTransaction) {
                    ForEach(transactions) { transaction in
                        TransactionView(
                            selectedTransaction: $selectedTransaction,
                            swipeActionsEnabled: true,
                            transaction: transaction,
                            displayingAccountId: selectedAccountId
                        )
                        .tag(transaction)
                    }
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
    }

    // MARK: - Empty States

    private var emptyTransactionsListView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            Text("This account has no transactions")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTransactionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Transaction Selected")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Select a transaction to view its details")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var filteredTransactions: [Transaction] {
        if selectedAccountId == allAccountsId {
            return dataManager.transactions
        } else if let selectedAccountId = selectedAccountId {
            return dataManager.transactions.filter {
                $0.accountId == selectedAccountId || $0.destinationAccountId == selectedAccountId
            }
        }
        return []
    }

    private var headerTitle: String {
        if selectedAccountId == allAccountsId {
            return "All Accounts"
        } else if let selectedAccountId = selectedAccountId,
                  let account = dataManager.accounts.first(where: { $0.id == selectedAccountId }) {
            return account.name
        }
        return "Transactions"
    }

    // MARK: - Helpers

    private func accountName(for accountId: UUID?) -> String {
        guard let accountId = accountId,
              let account = dataManager.accounts.first(where: { $0.id == accountId }) else {
            return "Unknown"
        }
        return account.name
    }

    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .certificateOfDeposit:
            return "doc.text"
        case .checking:
            return "checkmark.circle"
        case .creditCard:
            return "creditcard"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .retirement:
            return "leaf"
        case .saving:
            return "dollarsign.circle"
        }
    }
}

// MARK: - Supporting Views

struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.secondary)

            Text(account.name)
                .font(.body)
        }
        .padding(.leading, 8)
        .padding(.vertical, 2)
    }
}
