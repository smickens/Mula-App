//
//  TrendsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct TrendsView: View {
    @Environment(DataManager.self) private var dataManager
    
    @State private var selectedDate: Date = Date()
    @State private var selectedCategoryFilter: (any TransactionCategoryProtocol)?
    @State private var selectedAccountFilter: Account?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Header
            VStack(alignment: .leading) {
                Text("Spending Breakdown")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    monthSelector()
                    Spacer()
                    filterMenus()
                }
            }
            .padding(.horizontal)
            
            // MARK: - Main Content
            HStack(alignment: .top, spacing: 24) {
                DonutChartView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                CategoryListView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                    .frame(width: 350)
            }
            .padding(.horizontal)
            
            // MARK: - Bottom Summary
            summaryGrid()
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .background(Color(NSColor.windowBackgroundColor))
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

        if let category = selectedCategoryFilter {
            filteredTransactions = filteredTransactions.filter { $0.category.id == category.id }
        }

        if let account = selectedAccountFilter {
            filteredTransactions = filteredTransactions.filter { $0.sourceAccountId == account.id }
        }

        let totalSpending = filteredTransactions.reduce(0) { $0 + $1.amount }
        let spendingByCategory = dataManager.groupSpendingByCategory(transactions: filteredTransactions)

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

    private func monthSelector() -> some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? Date()
            }) {
                Image(systemName: "chevron.left")
            }
            
            Text(selectedDate.monthYearFormat())
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? Date()
            }) {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private func filterMenus() -> some View {
        HStack {
            Menu {
                Button("All Categories", action: { selectedCategoryFilter = nil })

                let allCategories: [any TransactionCategoryProtocol] = ExpenseCategory.allCases + IncomeCategory.allCases

                ForEach(allCategories, id: \.id) { category in
                    Button(category.displayName, action: { selectedCategoryFilter = category })
                }
            } label: {
                Text(selectedCategoryFilter?.displayName ?? "All Categories")
                Image(systemName: "chevron.down")
            }
            .menuStyle(.borderlessButton)
            
            Menu {
                Button("All Accounts", action: { selectedAccountFilter = nil })
                ForEach(dataManager.accounts) { account in
                    Button(account.name, action: { selectedAccountFilter = account })
                }
            } label: {
                Text(selectedAccountFilter?.name ?? "All Accounts")
                Image(systemName: "chevron.down")
            }
            .menuStyle(.borderlessButton)
        }
    }
    
    private func summaryGrid() -> some View {
        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 24) {
            GridRow {
                SummaryCardView(title: "Average Monthly Spending") {
                    Text(viewData.avgMonthlySpending.toCurrency())
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                SummaryCardView(title: "Average Daily Spending") {
                    Text(viewData.avgDailySpending.toCurrency())
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            GridRow {
                SummaryCardView(title: "Most Frequent Category") {
                    if let mostFrequent = viewData.mostFrequentCategory {
                        HStack {
                            Image(systemName: mostFrequent.category.iconName)
                            Text(mostFrequent.category.displayName)
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        Text("\(mostFrequent.count) transactions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                SummaryCardView(title: "Largest Outflow") {
                    if let largest = viewData.largestOutflow {
                        Text(largest.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(largest.amount.toCurrency())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
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

extension Date {
    func monthYearFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter.string(from: self)
    }
}
