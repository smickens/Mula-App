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
    @State private var isShowingMonthYearPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Header
            VStack(alignment: .leading) {
                monthSelector()
            }
            .padding(.horizontal)
            
            // MARK: - Main Content
            HStack(alignment: .top, spacing: 24) {
                DonutChartView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)

                CategoryListView(spendingByCategory: viewData.spendingByCategory, totalSpending: viewData.totalSpending)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
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
        filteredTransactions = filteredTransactions.filter { $0.kind.isExpense }

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
        HStack(spacing: 8) {
            Button(action: {
                moveSelectedMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)

            Button {
                isShowingMonthYearPicker.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")

                    Text(selectedDate.monthYearFormat())
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.title2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isShowingMonthYearPicker, arrowEdge: .bottom) {
                MonthYearPicker(selectedDate: $selectedDate)
                    .padding()
                    .frame(width: 320)
            }
            
            Button(action: {
                moveSelectedMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
        }
    }

    private func moveSelectedMonth(by value: Int) {
        selectedDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) ?? Date()
    }

    // TODO: rearrange to have 4 tiles under the pie chart and give the category breakdown more vertical
    // space to show more things
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

// TODO: move to separate file
private struct MonthYearPicker: View {
    @Binding var selectedDate: Date

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    private let months = Calendar.current.shortMonthSymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    selectedYear -= 1
                    applySelection()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.borderless)

                Spacer()

                Text(String(selectedYear))
                    .font(.headline)
                    .monospacedDigit()

                Spacer()

                Button {
                    selectedYear += 1
                    applySelection()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.borderless)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    Button {
                        selectedMonth = month
                        applySelection()
                    } label: {
                        Text(months[month - 1])
                            .font(.subheadline)
                            .fontWeight(selectedMonth == month ? .semibold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedMonth == month ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            .foregroundColor(selectedMonth == month ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            selectedMonth = Calendar.current.component(.month, from: selectedDate)
            selectedYear = Calendar.current.component(.year, from: selectedDate)
        }
    }

    private func applySelection() {
        var components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: selectedDate)
        components.year = selectedYear
        components.month = selectedMonth
        components.day = min(components.day ?? 1, daysInSelectedMonth)

        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
    }

    private var daysInSelectedMonth: Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1

        guard let date = Calendar.current.date(from: components),
              let range = Calendar.current.range(of: .day, in: .month, for: date) else {
            return 28
        }

        return range.count
    }
}

extension Date {
    func monthYearFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}
