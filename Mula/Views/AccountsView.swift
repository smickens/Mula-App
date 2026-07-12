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
    @SceneStorage("accounts.expandedSectionIDs") private var storedExpandedSectionData: Data?
    @SceneStorage("accounts.selection") private var storedAccountSelectionData: Data?
    @SceneStorage("accounts.selectedTimeframe") private var storedSelectedTimeframe: AccountsTimeframe = .lastMonth
    @State private var accountSelection: AccountSelection?
    @State private var selectedTransactionID: UUID?
    @State private var expandedSections: Set<AccountType> = []
    @State private var showingAddAccountSheet = false
    @State private var showingNewTransactionForm = false

    private let cornerRadius: CGFloat = 12
    private let panePadding: CGFloat = 12
    private let gridSpacing: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            pageHeader

            HStack(alignment: .top, spacing: gridSpacing) {
                accountsList
                    .frame(maxWidth: .infinity)

                VStack(spacing: gridSpacing) {
                    transactionsListView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    SummaryMetricsGrid(metrics: summaryMetrics, spacing: gridSpacing)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: storedSelectedTimeframe) { _, _ in
            selectedTransactionID = nil
        }
        .onChange(of: accountSelection) { _, _ in
            selectedTransactionID = nil
            storedAccountSelectionData = try? JSONEncoder().encode(accountSelection)
        }
        .onChange(of: expandedSections) { _, newValue in
            storedExpandedSectionData = try? JSONEncoder().encode(Array(newValue))
        }
        .sheet(isPresented: $showingAddAccountSheet) {
            AddAccountSheet()
        }
        .sheet(isPresented: $showingNewTransactionForm) {
            NewTransactionFormView()
        }
    }

    private var pageHeader: some View {
        HStack {
            Spacer()

            HStack(spacing: 10) {
                Button {
                    showingAddAccountSheet = true
                } label: {
                    Label("Add Account", systemImage: "plus.circle")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button {
                    showingNewTransactionForm = true
                } label: {
                    Label("New Transaction", systemImage: "plus.square")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Accounts List

    private var accountsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            AccountSelectionRow(
                title: "All Accounts",
                systemImage: "list.bullet.rectangle",
                isSelected: accountSelection == .allAccounts
            ) {
                accountSelection = .allAccounts
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(AccountType.allCases) { accountType in
                        let accountsOfType = accounts(for: accountType)

                        if !accountsOfType.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                accountTypeHeader(accountType, count: accountsOfType.count)

                                if expandedSections.contains(accountType) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(accountsOfType) { account in
                                            AccountRow(
                                                account: account,
                                                isSelected: accountSelection == .account(account.id),
                                                showDebugInfo: showDebugInfo
                                            ) {
                                                accountSelection = .account(account.id)
                                            }
                                        }
                                    }
                                    .padding(.leading, 8)
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
        .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            if let storedAccountSelectionData,
               let decodedSelection = try? JSONDecoder().decode(AccountSelection.self, from: storedAccountSelectionData),
               isValid(selection: decodedSelection) {
                accountSelection = decodedSelection
            } else if accountSelection == nil {
                accountSelection = .allAccounts
            }

            if let storedExpandedSectionData,
               let storedTypes = try? JSONDecoder().decode([AccountType].self, from: storedExpandedSectionData) {
                expandedSections = Set(storedTypes)
            } else {
                expandedSections = []
            }
        }
    }

    @ViewBuilder
    private func accountTypeHeader(_ type: AccountType, count: Int) -> some View {
        AccountTypeSelectionRow(
            title: type.displayName,
            systemImage: iconForAccountType(type),
            tintColor: colorForAccountType(type),
            count: count,
            isExpanded: expandedSections.contains(type),
            isSelected: accountSelection == .accountType(type),
            onSelect: {
                accountSelection = .accountType(type)
            },
            onToggleExpanded: {
                toggleSection(type)
            }
        )
    }

    private var displayingAccountId: UUID? {
        if case .account(let accountId) = accountSelection {
            return accountId
        }

        return nil
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
                            configuration: .standard(displayingAccountId: displayingAccountId)
                        )
                        .tag(transaction.id)
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(cornerRadius)
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
        .padding()
    }

    // MARK: - Computed Properties

    private var filteredTransactions: [Transaction] {
        transactionsInSelectedTimeframe
            .filter { transaction in
                switch accountSelection ?? .allAccounts {
                case .allAccounts:
                    return true
                case .account(let accountId):
                    let isFromAccount = transaction.sourceAccountId == accountId
                    let isToAccount = destinationAccountId(for: transaction) == accountId
                    return isFromAccount || isToAccount
                case .accountType(let type):
                    let sourceMatches = accountType(for: transaction.sourceAccountId) == type
                    let destinationMatches = destinationAccountId(for: transaction).flatMap(accountType(for:)) == type
                    return sourceMatches || destinationMatches
                }
            }
            .sorted { $0.date < $1.date }
    }

    private var transactionsInSelectedTimeframe: [Transaction] {
        dataManager.transactions.filter { storedSelectedTimeframe.contains($0.date) }
    }

    private var summaryMetrics: [SummaryMetric] {
        let scope = selectedScope
        let transactions = filteredTransactions

        switch scope {
        case .allAccounts:
            return [
                SummaryMetric(
                    title: "Money In",
                    primaryText: sumMoneyIn(for: transactions).toCurrency(),
                    primaryColor: .green
                ),
                SummaryMetric(
                    title: "Money Out",
                    primaryText: sumMoneyOut(for: transactions).toCurrency(),
                    primaryColor: .red
                )
            ]

        case .accountType(.creditCard), .accountType(.checking):
            let largestExpense = largestExpense(in: transactions)
            return [
                SummaryMetric(
                    title: "Total Spent",
                    primaryText: totalSpent(for: transactions).toCurrency(),
                    primaryColor: .red
                ),
                SummaryMetric(
                    title: "Largest Expense",
                    primaryText: largestExpense?.amount.toCurrency() ?? "--",
                    secondaryText: largestExpense?.displayTitle,
                    primaryColor: .red
                )
            ]

        case .accountType(.saving), .accountType(.certificateOfDeposit):
            return [
                SummaryMetric(
                    title: "Total Contributions",
                    primaryText: totalContributions(for: transactions).toCurrency()
                ),
                SummaryMetric(
                    title: "Interest Earned",
                    primaryText: interestEarned(for: transactions).toCurrency(),
                    primaryColor: .green
                )
            ]

        case .accountType(.investment):
            return [
                SummaryMetric(
                    title: "Total Contributions",
                    primaryText: totalContributions(for: transactions).toCurrency()
                ),
                SummaryMetric(
                    title: "Passive Income",
                    primaryText: passiveIncome(for: transactions).toCurrency(),
                    primaryColor: .green
                )
            ]

        case .accountType(.retirement):
            return [
                SummaryMetric(
                    title: "Total Contributions",
                    primaryText: totalContributions(for: transactions).toCurrency()
                ),
                SummaryMetric(
                    title: "Growth",
                    primaryText: retirementGrowth.toCurrencyOrPlaceholder,
                    secondaryText: retirementGrowth == nil ? "Need balance checkpoints" : nil,
                    primaryColor: (retirementGrowth ?? 0) < 0 ? .red : .green
                )
            ]
        }
    }

    private var selectedScope: AccountStatsScope {
        switch accountSelection ?? .allAccounts {
        case .allAccounts:
            return .allAccounts
        case .accountType(let type):
            return .accountType(type)
        case .account(let accountId):
            guard let account = dataManager.accounts.first(where: { $0.id == accountId }) else {
                return .allAccounts
            }
            return .accountType(account.type)
        }
    }

    private var retirementGrowth: Decimal? {
        guard case .accountType(.retirement) = selectedScope else {
            return nil
        }

        let accountIds = selectedAccountIDs
        let relevantStatements = dataManager.accountStatements
            .filter { accountIds.contains($0.accountId) }
            .filter { storedSelectedTimeframe.contains($0.date) }
            .sorted { $0.date < $1.date }

        guard let firstBalance = relevantStatements.first?.balance,
              let lastBalance = relevantStatements.last?.balance else {
            return nil
        }

        return (lastBalance - firstBalance) - totalContributions(for: filteredTransactions)
    }

    private var selectedAccountIDs: Set<UUID> {
        switch accountSelection ?? .allAccounts {
        case .allAccounts:
            return Set(dataManager.accounts.map(\.id))
        case .account(let accountId):
            return [accountId]
        case .accountType(let type):
            return Set(accounts(for: type).map(\.id))
        }
    }

    private var headerTitle: String {
        switch accountSelection ?? .allAccounts {
        case .allAccounts:
            return "All Accounts"
        case .accountType(let type):
            return type.displayName
        case .account(let accountId):
            if let account = dataManager.accounts.first(where: { $0.id == accountId }) {
            return account.name
            }
            return "Transactions"
        }
    }

    private var emptyTransactionsMessage: String {
        accountSelection == .allAccounts ? "No transactions in this period" : "This selection has no transactions in this period"
    }

    private func headerSubtitle(for transactionCount: Int) -> String {
        "\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")"
    }

    private var timeframeMenu: some View {
        Menu {
            ForEach(AccountsTimeframe.allCases) { timeframe in
                Button(timeframe.displayName) {
                    storedSelectedTimeframe = timeframe
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(storedSelectedTimeframe.displayName)
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

    private func accountType(for accountId: UUID) -> AccountType? {
        dataManager.accounts.first(where: { $0.id == accountId })?.type
    }

    private func isValid(selection: AccountSelection) -> Bool {
        switch selection {
        case .allAccounts, .accountType:
            return true
        case .account(let accountId):
            return dataManager.accounts.contains(where: { $0.id == accountId })
        }
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

    private func colorForAccountType(_ type: AccountType) -> Color {
        switch type {
        case .certificateOfDeposit:
            return .orange
        case .checking:
            return .blue
        case .creditCard:
            return .pink
        case .investment:
            return .green
        case .retirement:
            return .mint
        case .saving:
            return .indigo
        }
    }

    private func toggleSection(_ type: AccountType) {
        if expandedSections.contains(type) {
            expandedSections.remove(type)
        } else {
            expandedSections.insert(type)
        }
    }

    private func destinationAccountId(for transaction: Transaction) -> UUID? {
        guard case .transfer(_, let destinationAccountId) = transaction.kind else {
            return nil
        }

        return destinationAccountId
    }

    private func sumMoneyIn(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            switch transaction.kind {
            case .income:
                return partialResult + transaction.amount
            default:
                return partialResult
            }
        }
    }

    private func sumMoneyOut(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            switch transaction.kind {
            case .expense:
                return partialResult + transaction.amount
            default:
                return partialResult
            }
        }
    }

    private func totalSpent(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            guard case .expense = transaction.kind else {
                return partialResult
            }

            return partialResult + transaction.amount
        }
    }

    private func largestExpense(in transactions: [Transaction]) -> Transaction? {
        transactions
            .filter {
                if case .expense = $0.kind { return true }
                return false
            }
            .max { $0.amount < $1.amount }
    }

    private func totalContributions(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            guard case .saving(.contribution) = transaction.kind else {
                return partialResult
            }

            return partialResult + transaction.amount
        }
    }

    private func interestEarned(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            guard case .income(.interest) = transaction.kind else {
                return partialResult
            }

            return partialResult + transaction.amount
        }
    }

    private func passiveIncome(for transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { partialResult, transaction in
            switch transaction.kind {
            case .income(.interest), .income(.dividend):
                return partialResult + transaction.amount
            default:
                return partialResult
            }
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

private enum AccountSelection: Hashable, Codable {
    case allAccounts
    case accountType(AccountType)
    case account(UUID)
}

private enum AccountStatsScope {
    case allAccounts
    case accountType(AccountType)
}

private extension Optional where Wrapped == Decimal {
    var toCurrencyOrPlaceholder: String {
        self?.toCurrency() ?? "--"
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
            .padding(.vertical, 7)
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

private struct AccountTypeSelectionRow: View {
    let title: String
    let systemImage: String
    let tintColor: Color
    let count: Int
    let isExpanded: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleExpanded: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggleExpanded) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 12)
            }
            .buttonStyle(.plain)

            Button(action: onSelect) {
                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(tintColor)
                        .frame(width: 18)

                    Text(title)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.10) : Color.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor.opacity(0.22) : Color.clear, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }
}
