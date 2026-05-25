//
//  TrendsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

// TODO: add a way to click on a category from the Donut Chart or the Category List and pull up a view of
// the transactions in that category for the given month and year

// TODO: add a category menu that is multi-select to choose which categories are included in the breakdown

// TODO: update avg. monthly spending to take into account the current month (and the previous 3-6 or something, if those past months have a min. amount of data)

// TODO: start the month selection on launch at the previous month (more likely to have data inputed since i use statements from the end of the month)

struct TrendsView: View {
    @Environment(DataManager.self) private var dataManager
    
    @State private var selectedDate: Date = Date()

    let kGridSpacing: CGFloat = 24
    let kCornerRadius: CGFloat = 12

    // TODO: add some kind of total vs. my spending toggle
    // where my spending could filter down based on a personalShare concept on expense
    var body: some View {
        VStack(alignment: .leading, spacing: kGridSpacing) {
            // MARK: - Header
            DatePeriodSelector(selectedDate: $selectedDate, granularity: .month)

            // MARK: - Main Content
            HStack(alignment: .top, spacing: kGridSpacing) {
                VStack(spacing: kGridSpacing) {
                    DonutChartView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(kCornerRadius)

                    SummaryMetricsGrid(metrics: summaryMetrics, spacing: kGridSpacing)
                }

                CategoryListView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(kCornerRadius)
            }
        }
        .padding()
    }

    private var viewData: ViewData {
        let calendar = Calendar.current
        guard let dateInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return ViewData(totalSpending: 0,
                            spendingByCategory: [],
                            avgMonthlySpending: 0,
                            avgDailySpending: 0,
                            mostFrequentCategory: nil,
                            largestOutflow: nil)
        }

        var filteredTransactions = dataManager.transactions(from: dateInterval.start, to: dateInterval.end)
        filteredTransactions = filteredTransactions.filter { $0.kind.isSpendingAnalyticsEligible }

        let totalSpending = filteredTransactions.reduce(0) { $0 + $1.amount }
        let spendingByCategory = dataManager.groupSpendingByCategory(transactions: filteredTransactions, maxCategories: 10)

        // TODO: should take into account selectedMonth
        let avgMonthlySpending = dataManager.calculateAverageMonthlySpending(forLastMonths: 12)

        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let avgDailySpending = totalSpending / Decimal(daysInMonth)

        let mostFrequentCategory = dataManager.mostFrequentCategory(in: filteredTransactions)
        let largestOutflow = dataManager.largestTransaction(in: filteredTransactions)

        return ViewData(totalSpending: totalSpending,
                        spendingByCategory: spendingByCategory,
                        avgMonthlySpending: avgMonthlySpending,
                        avgDailySpending: avgDailySpending,
                        mostFrequentCategory: mostFrequentCategory,
                        largestOutflow: largestOutflow)
    }

    private var summaryMetrics: [SummaryMetric] {
        [
            SummaryMetric(
                title: "Average Monthly Spending",
                primaryText: viewData.avgMonthlySpending.toCurrency()
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
                secondaryText: viewData.largestOutflow?.amount.toCurrency()
            )
        ]
    }
    
    struct ViewData {
        let totalSpending: Decimal
        let spendingByCategory: [DataManager.CategorySpending]
        let avgMonthlySpending: Decimal
        let avgDailySpending: Decimal
        let mostFrequentCategory: (category: any TransactionCategoryProtocol, count: Int)?
        let largestOutflow: Transaction?
    }
}
