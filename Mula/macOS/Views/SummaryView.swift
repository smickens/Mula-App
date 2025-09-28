//
//  SummaryView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct SummaryView: View {
    @Binding var selectedCategory: Category?
    let expensesForMonth: [Expense]
    let totalsByCategory: [Category: Double]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(alignment: .bottom) {
//                Text("Spending in \(expensesForMonth.first?.date.month ?? "xxx")")
//                    .font(.headline)

                Text(totalMoneyIn + totalMoneyOut, format: .currency(code: "USD"))
                    .font(.title)
                    .fontWeight(.medium)

                Text("in \(expensesForMonth.first?.date.month ?? "xxx")")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.bottom)

            ChartView(expenses: expensesForMonth)

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
    
    private var totalMoneyIn: Double {
        return 0 //expensesForMonth.filter { $0.category == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalMoneyOut: Double {
        return expensesForMonth.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading, spacing: 5) {
                ForEach(Category.allCases, id: \.self) { category in
//                    if category != .income {
                        getCategoryView(for: category)
//                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func getCategoryView(for category: Category) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(category.tintColor)
                    .frame(width: 28, height: 28)

                Image(systemName: category.iconName)
                    .foregroundColor(.white)
            }

            Spacer()

            Text(totalsByCategory[category] ?? 0.0, format: .currency(code: "USD"))
        }
        .padding(.horizontal)
        .border(Color.blue, width: selectedCategory == category ? 1 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCategory = category == selectedCategory ? nil : category
        }
    }
}


