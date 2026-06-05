//
//  TrendsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct TrendsView: View {
    @Environment(DataManager.self) private var dataManager
    
    @Binding var selectedDate: Date
    @State private var selectedTransactionID: UUID?
    @State private var selectedCategoryId: String?
    @State private var spendingMode: SpendingMode = .personal

    let kGridSpacing: CGFloat = 24
    let kCornerRadius: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: kGridSpacing) {
            // MARK: - Header
            HStack {
                DatePeriodSelector(selectedDate: $selectedDate, granularity: .month)

                Spacer()

                Picker("Spending Mode", selection: $spendingMode) {
                    ForEach(SpendingMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
                .labelsHidden()
            }

            // MARK: - Main Content
            HStack(alignment: .top, spacing: kGridSpacing) {
                VStack(spacing: kGridSpacing) {
                    DonutChartView(
                        spendingByCategory: viewData.spendingByCategory,
                        totalSpending: viewData.totalSpending,
                        spendingTitle: spendingMode.displayName,
                        selectedCategoryId: $selectedCategoryId
                    )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(kCornerRadius)

                    SummaryMetricsGrid(metrics: summaryMetrics, spacing: kGridSpacing)
                }

                VStack(spacing: kGridSpacing) {
                    CategoryListView(
                        spendingByCategory: viewData.spendingByCategory,
                        totalSpending: viewData.totalSpending,
                        spendingTitle: spendingMode.displayName,
                        selectedCategoryId: $selectedCategoryId
                    )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(kCornerRadius)

                    transactionsList
                }
            }
        }
        .padding()
    }

    private var viewData: ViewData {
        let calendar = Calendar.current
        guard let dateInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return ViewData(totalSpending: 0,
                            spendingByCategory: [],
                            avgMonthlySpending: nil,
                            avgDailySpending: 0,
                            mostFrequentCategory: nil,
                            largestOutflow: nil,
                            largestOutflowAmount: nil,
                            transactions: [])
        }

        var filteredTransactions = dataManager.transactions(from: dateInterval.start, to: dateInterval.end)
        filteredTransactions = filteredTransactions.filter { $0.kind.isSpendingAnalyticsEligible }

        let amount = spendingMode.amount
        let totalSpending = filteredTransactions.reduce(0) { $0 + amount($1) }
        let spendingByCategory = dataManager.groupSpendingByCategory(
            transactions: filteredTransactions,
            maxCategories: 10,
            amount: amount
        )

        let avgMonthlySpending = dataManager.calculateAverageMonthlySpending(
            forLastMonths: 6,
            endingAt: selectedDate,
            amount: amount
        )

        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let avgDailySpending = totalSpending / Decimal(daysInMonth)

        let transactionsForMostFrequentCategory: [Transaction]
        switch spendingMode {
        case .personal:
            transactionsForMostFrequentCategory = filteredTransactions.filter { $0.mySpendingAmount > 0 }
        case .total:
            transactionsForMostFrequentCategory = filteredTransactions
        }

        let mostFrequentCategory = dataManager.mostFrequentCategory(in: transactionsForMostFrequentCategory)
        let largestOutflow = dataManager.largestTransaction(in: filteredTransactions, amount: amount)
        let largestOutflowAmount = largestOutflow.map(amount)

        return ViewData(totalSpending: totalSpending,
                        spendingByCategory: spendingByCategory,
                        avgMonthlySpending: avgMonthlySpending,
                        avgDailySpending: avgDailySpending,
                        mostFrequentCategory: mostFrequentCategory,
                        largestOutflow: largestOutflow,
                        largestOutflowAmount: largestOutflowAmount,
                        transactions: filteredTransactions.sorted { $0.date > $1.date })
    }

    private var summaryMetrics: [SummaryMetric] {
        [
            SummaryMetric(
                title: "Average Monthly Spending",
                primaryText: viewData.avgMonthlySpending?.toCurrency() ?? "--"
            ),
            SummaryMetric(
                title: "Average Daily Spending",
                primaryText: viewData.avgDailySpending.toCurrency()
            ),
            SummaryMetric(
                title: "Most Frequent Category",
                primaryText: viewData.mostFrequentCategory?.category.displayName ?? "N/A",
                secondaryText: viewData.mostFrequentCategory.map { "\($0.count) transactions" },
                iconName: viewData.mostFrequentCategory?.category.iconName
            ),
            SummaryMetric(
                title: "Largest Outflow",
                primaryText: viewData.largestOutflow?.displayTitle ?? "N/A",
                secondaryText: viewData.largestOutflowAmount?.toCurrency()
            )
        ]
    }

    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transactions")
                    .font(.headline)

                Spacer()

                categoryFilterMenu
            }
            .padding([.horizontal, .top])

            if filteredTransactionsForSelectedCategory.isEmpty {
                Text(emptyTransactionsMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            } else {
                List(selection: $selectedTransactionID) {
                    ForEach(filteredTransactionsForSelectedCategory) { transaction in
                        TransactionView(
                            selectedTransactionID: $selectedTransactionID,
                            swipeActionsEnabled: true,
                            transaction: transaction,
                            configuration: spendingMode.transactionViewConfiguration
                        )
                        .tag(transaction.id)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(kCornerRadius)
    }

    private var filteredTransactionsForSelectedCategory: [Transaction] {
        guard let selectedCategoryId else {
            return viewData.transactions
        }

        return viewData.transactions.filter { $0.category.id == selectedCategoryId }
    }

    private var categoryFilterMenu: some View {
        Menu {
            Button("All Categories") {
                selectedCategoryId = nil
            }

            Divider()

            ForEach(viewData.spendingByCategory) { categorySpending in
                Button(categorySpending.category.displayName) {
                    selectedCategoryId = categorySpending.category.id
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedCategoryName)
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

    private var selectedCategoryName: String {
        guard let selectedCategoryId,
              let category = viewData.spendingByCategory.first(where: { $0.category.id == selectedCategoryId })?.category else {
            return "All Categories"
        }

        return category.displayName
    }

    private var emptyTransactionsMessage: String {
        return selectedCategoryId == nil ? "No spending transactions" : "No transactions for this category"
    }
    
    struct ViewData {
        let totalSpending: Decimal
        let spendingByCategory: [DataManager.CategorySpending]
        let avgMonthlySpending: Decimal?
        let avgDailySpending: Decimal
        let mostFrequentCategory: (category: any TransactionCategoryProtocol, count: Int)?
        let largestOutflow: Transaction?
        let largestOutflowAmount: Decimal?
        let transactions: [Transaction]
    }
}

private enum SpendingMode: CaseIterable, Identifiable {
    case personal
    case total

    var id: Self { self }

    var displayName: String {
        switch self {
        case .personal:
            return "My Spending"
        case .total:
            return "All Spending"
        }
    }

    var amount: (Transaction) -> Decimal {
        switch self {
        case .personal:
            return { $0.mySpendingAmount }
        case .total:
            return { $0.amount }
        }
    }

    var transactionViewConfiguration: TransactionViewConfiguration {
        switch self {
        case .personal:
            return .mySpending
        case .total:
            return .allSpending
        }
    }
}
