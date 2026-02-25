//
//  SummaryView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct SummaryView: View {
    @Binding var selectedCategory: (any TransactionCategoryProtocol)?
    let transactionsForMonth: [Transaction]
    let totalsByCategory: [(any TransactionCategoryProtocol, Decimal)]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(alignment: .bottom) {
//                Text("Spending in \(expensesForMonth.first?.date.month ?? "xxx")")
//                    .font(.headline)

                Text(totalMoneyIn + totalMoneyOut, format: .currency(code: "USD"))
                    .font(.title)
                    .fontWeight(.medium)

                Text("in \(transactionsForMonth.first?.date.month ?? "xxx")")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.bottom)

            ChartView(transactions: transactionsForMonth)

//            Text("Spending Overview")
//                .font(.headline)
//                .padding(.bottom)
//
//            spendingOverview

            Text("Category Breakdown")
                .font(.headline)
                .padding(.vertical)

            PieChartView(
                selectedCategory: $selectedCategory,
                totalsByCategory: totalsByCategory
            )
                .frame(width: 160, height: 160)

            categoryBreakdown
            
            Spacer()
        }
        .padding()
    }

    private var spendingOverview: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 5) {
            GridRow {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30, weight: .semibold))

                Text("+")

                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 30, weight: .semibold))

                Text("=")

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
            }
            GridRow {
                Text(totalMoneyIn, format: .currency(code: "USD"))
                    .frame(maxWidth: .infinity)

                Text("+")

                Text(totalMoneyOut, format: .currency(code: "USD"))
                    .frame(maxWidth: .infinity)

                Text("=")

                Text(totalMoneyIn + totalMoneyOut, format: .currency(code: "USD"))
                    .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.gray)
    }
    
    private var totalMoneyIn: Decimal {
        return 0 //expensesForMonth.filter { $0.category == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalMoneyOut: Decimal {
        return transactionsForMonth.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading, spacing: 5) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
//                    if category != .income {
                        getCategoryView(for: category)
//                    }
                }
//                ForEach(IncomeCategory.allCases, id: \.self) { category in
//                    getCategoryView(for: category)
//                }
            }
            .padding(.horizontal)
        }
    }

    private func getCategoryView(for category: (any TransactionCategoryProtocol)) -> some View {
        let isMatchingCategory = {
            guard let selectedCategory else { return false }
            return selectedCategory.id == category.id
        }()

        return HStack {
            ZStack {
                Circle()
                    .fill(category.baseColor)
                    .frame(width: 28, height: 28)

                Image(systemName: category.iconName)
                    .foregroundColor(.white)
            }

            Spacer()

            let categoryTotal = (totalsByCategory.first { $0.0.id == category.id })?.1 ?? 0.0
            Text(categoryTotal, format: .currency(code: "USD"))
        }
        .padding(.horizontal)
        .border(Color.blue, width: isMatchingCategory ? 1 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCategory = isMatchingCategory ? nil : category
        }
    }
}


