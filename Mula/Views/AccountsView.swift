//
//  AccountsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI
import MulaCore

struct AccountsView: View {
    @Environment(DataManager.self) private var dataManager
    @AppStorage(AppDefaults.Debug.showDebugInfoKey) private var showDebugInfo = false
    @State private var selectedAccountId: UUID?
    @State private var selectedTransactionID: UUID?
    @State private var expandedSections: Set<AccountType> = Set(AccountType.allCases)
    @State private var selectedTimeframe: AccountsTimeframe = .lastMonth
    @State private var showingAddAccountSheet = false
    @State private var showingNewTransactionForm = false

    private let cornerRadius: CGFloat = 12
    private let panePadding: CGFloat = 16
    private let gridSpacing: CGFloat = 16

    // Special UUID to represent "All Accounts"
    private let allAccountsId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    var body: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            pageHeader

            HStack(spacing: 0) {
                accountsList

                Divider()

                transactionsListView

                Divider()

                if let selectedTransactionID,
                   let selectedTransaction = filteredTransactions.first(where: { $0.id == selectedTransactionID }) {
                    TransactionDetailView(transaction: selectedTransaction, displayingAccountId: selectedAccountId)
                } else {
                    emptyTransactionView
                }
            }
        }
        .padding()
        .navigationTitle("Accounts")
        .onAppear {
            logAccountDebugInfoIfNeeded()
        }
        .onChange(of: showDebugInfo) { _, _ in
            logAccountDebugInfoIfNeeded()
        }
        .onChange(of: dataManager.accounts) { _, _ in
            logAccountDebugInfoIfNeeded()
        }
        .onChange(of: selectedTimeframe) { _, _ in
            selectedTransactionID = nil
        }
        .sheet(isPresented: $showingAddAccountSheet) {
            AddAccountSheet()
        }
        .sheet(isPresented: $showingNewTransactionForm) {
            NewTransactionFormView()
        }
    }

    private var pageHeader: some View {
        HStack(alignment: .center) {
            Spacer()

            Menu {
                Button {
                    showingAddAccountSheet = true
                } label: {
                    Label("Add Account", systemImage: "plus.circle")
                }

                Button {
                    showingNewTransactionForm = true
                } label: {
                    Label("New Transaction", systemImage: "plus.square")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 34, height: 34)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
    }

    // MARK: - Accounts List

    private var accountsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            AccountSelectionRow(
                title: "All Accounts",
                systemImage: "list.bullet.rectangle",
                isSelected: selectedAccountId == allAccountsId
            ) {
                selectedAccountId = allAccountsId
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(AccountType.allCases) { accountType in
                        let accountsOfType = accounts(for: accountType)

                        if !accountsOfType.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                accountTypeHeader(accountType, count: accountsOfType.count)

                                if expandedSections.contains(accountType) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(accountsOfType) { account in
                                            AccountRow(
                                                account: account,
                                                isSelected: selectedAccountId == account.id,
                                                showDebugInfo: showDebugInfo
                                            ) {
                                                selectedAccountId = account.id
                                            }
                                        }
                                    }
                                    .padding(.leading, 10)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(panePadding)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(cornerRadius)
        .frame(minWidth: 220, idealWidth: 280, maxWidth: 320)
        .onAppear {
            if selectedAccountId == nil {
                selectedAccountId = allAccountsId
            }
        }
    }

    @ViewBuilder
    private func accountTypeHeader(_ type: AccountType, count: Int) -> some View {
        Button {
            toggleSection(type)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: expandedSections.contains(type) ? "chevron.down" : "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 12)

                Image(systemName: iconForAccountType(type))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 18)

                Text(type.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Transactions List

    private var transactionsListView: some View {
        let transactions = filteredTransactions

        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(headerTitle)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(headerSubtitle(for: transactions.count))
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

                    Spacer()

                    timeframeMenu
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if transactions.isEmpty {
                emptyTransactionsListView
            } else {
                List(selection: $selectedTransactionID) {
                    ForEach(transactions) { transaction in
                        TransactionView(
                            selectedTransactionID: $selectedTransactionID,
                            swipeActionsEnabled: true,
                            transaction: transaction,
                            configuration: .standard(displayingAccountId: selectedAccountId)
                        )
                        .tag(transaction.id)
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
            Text(emptyTransactionsMessage)
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
        transactionsInSelectedTimeframe
            .filter {
                let isAllAccountsSelected = selectedAccountId == allAccountsId
                let isFromAccount = $0.sourceAccountId == selectedAccountId
                var isToAccount = false
                if case .transfer(_, let destinationAccountId) = $0.kind {
                    isToAccount = destinationAccountId == selectedAccountId
                }
                return isAllAccountsSelected || isFromAccount || isToAccount
            }
            .sorted { $0.date < $1.date }
    }

    private var transactionsInSelectedTimeframe: [Transaction] {
        dataManager.transactions.filter { selectedTimeframe.contains($0.date) }
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

    private var emptyTransactionsMessage: String {
        selectedAccountId == allAccountsId ? "No transactions in this period" : "This selection has no transactions in this period"
    }

    private func headerSubtitle(for transactionCount: Int) -> String {
        "\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")"
    }

    private var timeframeMenu: some View {
        Menu {
            ForEach(AccountsTimeframe.allCases) { timeframe in
                Button(timeframe.displayName) {
                    selectedTimeframe = timeframe
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedTimeframe.displayName)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
            .frame(maxWidth: 180)
        }
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
    }

    private func accounts(for type: AccountType) -> [Account] {
        dataManager.accounts.filter { $0.type == type }
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

    private func toggleSection(_ type: AccountType) {
        if expandedSections.contains(type) {
            expandedSections.remove(type)
        } else {
            expandedSections.insert(type)
        }
    }

    private func logAccountDebugInfoIfNeeded() {
        guard showDebugInfo else { return }

        for account in dataManager.accounts.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) {
            print("🐛 Account UUID [\(account.name)]: \(account.id.uuidString)")
        }
    }
}

private enum AccountsTimeframe: String, CaseIterable, Identifiable {
    case lastMonth
    case last3Months
    case last6Months
    case yearToDate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lastMonth:
            return "Last Month"
        case .last3Months:
            return "Last 3 Months"
        case .last6Months:
            return "Last 6 Months"
        case .yearToDate:
            return "Year to Date"
        }
    }

    func contains(_ date: Date, relativeTo referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let endDate = referenceDate
        let startOfToday = calendar.startOfDay(for: referenceDate)

        switch self {
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: referenceDate),
                  let interval = calendar.dateInterval(of: .month, for: lastMonth) else {
                return false
            }

            return date >= interval.start && date < interval.end
        case .last3Months:
            guard let startDate = calendar.date(byAdding: .month, value: -3, to: startOfToday) else {
                return false
            }

            return date >= startDate && date <= endDate
        case .last6Months:
            guard let startDate = calendar.date(byAdding: .month, value: -6, to: startOfToday) else {
                return false
            }

            return date >= startDate && date <= endDate
        case .yearToDate:
            guard let interval = calendar.dateInterval(of: .year, for: referenceDate) else {
                return false
            }

            return date >= interval.start && date <= endDate
        }
    }
}

// MARK: - Supporting Views

struct AccountRow: View {
    let account: Account
    let isSelected: Bool
    let showDebugInfo: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.55))
                        .frame(width: 6, height: 6)

                    Text(account.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer(minLength: 0)
                }

                if showDebugInfo {
                    Text(account.id.uuidString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                        .padding(.leading, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor.opacity(0.25) : Color.clear, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct AccountSelectionRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.04))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.28) : Color.primary.opacity(0.05), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
