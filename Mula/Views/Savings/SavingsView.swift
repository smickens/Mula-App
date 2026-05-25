//
//  SavingsView.swift
//  Mula
//
//  Created by Codex on 5/25/26.
//

import Charts
import SwiftUI

struct SavingsView: View {
    @Environment(DataManager.self) private var dataManager

    @State private var selectedAccountId: UUID?
    @State private var isShowingCheckpointSheet = false

    private enum Layout {
        static let spacing: CGFloat = 24
        static let cardCornerRadius: CGFloat = 12
        static let chartHeight: CGFloat = 360
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            header

            GeometryReader { geometry in
                HStack(alignment: .top, spacing: Layout.spacing) {
                    VStack(spacing: Layout.spacing) {
                        savingsChart
                        SummaryMetricsGrid(metrics: summaryMetrics, spacing: Layout.spacing)
                    }
                    .frame(width: contentWidth(in: geometry.size.width, share: 2))
                    .frame(maxHeight: .infinity)

                    recentActivity
                        .frame(width: contentWidth(in: geometry.size.width, share: 1))
                        .frame(maxHeight: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(Layout.cardCornerRadius)
                }
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingCheckpointSheet) {
            BalanceCheckpointForm(
                accounts: savingsAccounts,
                selectedAccountId: selectedAccountId,
                onSave: { statement in
                    dataManager.addAccountStatement(statement)
                    isShowingCheckpointSheet = false
                },
                onCancel: {
                    isShowingCheckpointSheet = false
                }
            )
        }
    }

    func contentWidth(in totalWidth: CGFloat, share: CGFloat) -> CGFloat {
        let availableWidth = totalWidth - Layout.spacing
        return max(0, availableWidth * share / 3)
    }
}

private extension SavingsView {
    var header: some View {
        HStack(spacing: 12) {
            Text("Savings")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Picker("Account", selection: $selectedAccountId) {
                Text("All Savings Accounts").tag(UUID?.none)

                ForEach(savingsAccounts) { account in
                    Text(account.name).tag(Optional(account.id))
                }
            }
            .frame(width: 260)

            Button {
                isShowingCheckpointSheet = true
            } label: {
                Label("Add Checkpoint", systemImage: "plus")
            }
        }
    }

    var summaryMetrics: [SummaryMetric] {
        let growthColor: Color = viewData.growth >= 0 ? .green : .red

        return [
            SummaryMetric(
                title: "Current Value",
                primaryText: viewData.currentValue.toCurrency()
            ),
            SummaryMetric(
                title: "Net Contributions",
                primaryText: viewData.netContributions.toCurrency()
            ),
            SummaryMetric(
                title: "Growth",
                primaryText: viewData.growth.toCurrency(),
                primaryColor: growthColor
            ),
            SummaryMetric(
                title: "Growth %",
                primaryText: viewData.growthPercent,
                primaryColor: growthColor
            )
        ]
    }

    var savingsChart: some View {
        Chart {
            ForEach(viewData.chartPoints) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Baseline", 0),
                    yEnd: .value("Net Contributions", point.netContributionsDouble)
                )
                .foregroundStyle(by: .value("Series", "Net Contributions (shading)"))
                .interpolationMethod(.linear)

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.netContributionsDouble)
                )
                .foregroundStyle(by: .value("Series", "Net Contributions"))
                .interpolationMethod(.linear)
            }

            ForEach(viewData.chartPoints) { point in
                if let accountValue = point.accountValueDouble {
                    AreaMark(
                        x: .value("Date", point.date),
                        yStart: .value("Net Contributions", point.netContributionsDouble),
                        yEnd: .value("Account Value", accountValue)
                    )
                    .foregroundStyle(by: .value("Series", "Account Value (shading)"))
                    .interpolationMethod(.linear)

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Amount", accountValue)
                    )
                    .foregroundStyle(by: .value("Series", "Account Value"))
                    .interpolationMethod(.linear)
                }
            }
        }
        .chartForegroundStyleScale([
            "Net Contributions": Color.blue,
            "Net Contributions (shading)": Color.blue.opacity(0.10),
            "Account Value": Color.green,
            "Account Value (shading)": Color.green.opacity(0.10),
        ])
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(Decimal(amount).toCurrency())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: Layout.chartHeight)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(Layout.cardCornerRadius)
    }

    var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .padding([.horizontal, .top])

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewData.recentActivity) { item in
                        HStack(spacing: 12) {
                            Text(Self.activityDateFormatter.string(from: item.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 64, alignment: .leading)

                            Image(systemName: item.iconName)
                                .foregroundColor(item.color)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(item.accountName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(item.amount.toCurrency())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 10)

                        if item.id != viewData.recentActivity.last?.id {
                            Divider()
                        }
                    }

                    if viewData.recentActivity.isEmpty {
                        Text("No recent savings activity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private extension SavingsView {
    var viewData: SavingsViewData {
        let accountIds = selectedAccountIds
        let statements = dataManager.accountStatements
            .filter { accountIds.contains($0.accountId) }
        let savingTransactions = dataManager.transactions
            .filter { accountIds.contains($0.sourceAccountId) && $0.kind.isSaving }
        let relevantIncomeTransactions = dataManager.transactions
            .filter { transaction in
                guard accountIds.contains(transaction.sourceAccountId) else { return false }
                guard case .income(let category) = transaction.kind else { return false }
                return category == .interest || category == .dividend
            }

        let currentValue = latestValueByAccount(from: statements).values.reduce(0, +)
        let netContributions = netContributions(from: savingTransactions)
        let growth = currentValue - netContributions
        let chartPoints = chartPoints(statements: statements, savingTransactions: savingTransactions, accountIds: accountIds)
        let recentActivity = recentActivityItems(
            statements: statements,
            savingTransactions: savingTransactions,
            incomeTransactions: relevantIncomeTransactions
        )

        return SavingsViewData(
            currentValue: currentValue,
            netContributions: netContributions,
            growth: growth,
            growthPercent: growthPercent(growth: growth, netContributions: netContributions),
            chartPoints: chartPoints,
            recentActivity: recentActivity
        )
    }

    var savingsAccounts: [Account] {
        dataManager.accounts
            .filter { account in
                switch account.type {
                case .certificateOfDeposit, .investment, .retirement, .saving:
                    return true
                case .checking, .creditCard:
                    return false
                }
            }
            .sorted { $0.name < $1.name }
    }

    var selectedAccountIds: Set<UUID> {
        if let selectedAccountId {
            return [selectedAccountId]
        }

        return Set(savingsAccounts.map(\.id))
    }

    func latestValueByAccount(from statements: [AccountStatement]) -> [UUID: Decimal] {
        statements.reduce(into: [UUID: AccountStatement]()) { result, statement in
            guard let existing = result[statement.accountId] else {
                result[statement.accountId] = statement
                return
            }

            if statement.date > existing.date {
                result[statement.accountId] = statement
            }
        }
        .mapValues(\.balance)
    }

    func netContributions(from transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { total, transaction in
            switch transaction.kind {
            case .saving(.contribution):
                return total + transaction.amount
            case .saving(.withdrawal):
                return total - transaction.amount
            case .expense, .income, .transfer:
                return total
            }
        }
    }

    func chartPoints(
        statements: [AccountStatement],
        savingTransactions: [Transaction],
        accountIds: Set<UUID>
    ) -> [SavingsChartPoint] {
        let dates = Set(statements.map(\.date) + savingTransactions.map(\.date)).sorted()

        return dates.map { date in
            let netContributions = netContributions(from: savingTransactions.filter { $0.date <= date })
            let accountValue = accountValue(on: date, statements: statements, accountIds: accountIds)

            return SavingsChartPoint(
                date: date,
                netContributions: netContributions,
                accountValue: accountValue
            )
        }
    }

    func accountValue(
        on date: Date,
        statements: [AccountStatement],
        accountIds: Set<UUID>
    ) -> Decimal? {
        let latestStatements = accountIds.compactMap { accountId -> AccountStatement? in
            statements
                .filter { $0.accountId == accountId && $0.date <= date }
                .max { $0.date < $1.date }
        }

        guard !latestStatements.isEmpty else { return nil }
        return latestStatements.reduce(0) { $0 + $1.balance }
    }

    func recentActivityItems(
        statements: [AccountStatement],
        savingTransactions: [Transaction],
        incomeTransactions: [Transaction]
    ) -> [SavingsActivityItem] {
        let statementItems = statements.map { statement in
            SavingsActivityItem(
                date: statement.date,
                title: "Balance checkpoint",
                accountName: accountName(for: statement.accountId),
                amount: statement.balance,
                iconName: "flag.checkered",
                color: .green
            )
        }

        let savingItems = savingTransactions.map { transaction in
            SavingsActivityItem(
                date: transaction.date,
                title: transaction.displayTitle,
                accountName: accountName(for: transaction.sourceAccountId),
                amount: transaction.amount,
                iconName: transaction.category.iconName,
                color: transaction.amountColor()
            )
        }

        let incomeItems = incomeTransactions.map { transaction in
            SavingsActivityItem(
                date: transaction.date,
                title: transaction.displayTitle,
                accountName: accountName(for: transaction.sourceAccountId),
                amount: transaction.amount,
                iconName: transaction.category.iconName,
                color: transaction.category.baseColor
            )
        }

        return (statementItems + savingItems + incomeItems)
            .sorted { $0.date > $1.date }
            .prefix(8)
            .map { $0 }
    }

    func growthPercent(growth: Decimal, netContributions: Decimal) -> String {
        guard netContributions != 0 else { return "N/A" }

        let percent = (growth / netContributions) as NSDecimalNumber
        return Self.percentFormatter.string(from: percent) ?? "N/A"
    }

    func accountName(for accountId: UUID) -> String {
        dataManager.accounts.first { $0.id == accountId }?.name ?? "Unknown Account"
    }

    static let activityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}

private struct BalanceCheckpointForm: View {
    let accounts: [Account]
    let selectedAccountId: UUID?
    let onSave: (AccountStatement) -> Void
    let onCancel: () -> Void

    @State private var accountId: UUID
    @State private var date: Date = Date()
    @State private var balanceString = ""
    @State private var errorMessage: String?

    init(
        accounts: [Account],
        selectedAccountId: UUID?,
        onSave: @escaping (AccountStatement) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.accounts = accounts
        self.selectedAccountId = selectedAccountId
        self.onSave = onSave
        self.onCancel = onCancel
        _accountId = State(initialValue: selectedAccountId ?? accounts.first?.id ?? Account.default)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add Balance Checkpoint")
                .font(.title2)
                .fontWeight(.semibold)

            Picker("Account", selection: $accountId) {
                ForEach(accounts) { account in
                    Text(account.name).tag(account.id)
                }
            }

            DatePicker("Date", selection: $date, displayedComponents: .date)

            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                TextField("0.00", text: $balanceString)
                    .textFieldStyle(.roundedBorder)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            HStack {
                Spacer()

                Button("Cancel", role: .cancel) {
                    onCancel()
                }

                Button("Save") {
                    save()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 380)
    }

    private func save() {
        guard let balance = Decimal(string: balanceString),
              balance >= 0 else {
            errorMessage = "Enter a valid balance."
            return
        }

        onSave(
            AccountStatement(
                accountId: accountId,
                date: date,
                balance: balance
            )
        )
    }
}

private struct SavingsViewData {
    let currentValue: Decimal
    let netContributions: Decimal
    let growth: Decimal
    let growthPercent: String
    let chartPoints: [SavingsChartPoint]
    let recentActivity: [SavingsActivityItem]
}

private struct SavingsChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let netContributions: Decimal
    let accountValue: Decimal?

    var netContributionsDouble: Double {
        (netContributions as NSDecimalNumber).doubleValue
    }

    var accountValueDouble: Double? {
        accountValue.map { ($0 as NSDecimalNumber).doubleValue }
    }
}

private struct SavingsActivityItem: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let accountName: String
    let amount: Decimal
    let iconName: String
    let color: Color
}
