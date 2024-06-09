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
        VStack(alignment: .center) {
            Text("Spending Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom)

            spendingOverview

            Text("Category Totals")
                .font(.title2)
                .fontWeight(.semibold)

            PieChartView(
                selectedCategory: $selectedCategory,
                totalsByCategory: totalsByCategory
            )
                .frame(width: 160, height: 160)

            categoryBreakdown
        }
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
        return expensesForMonth.filter { $0.category == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalMoneyOut: Double {
        return expensesForMonth.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading, spacing: 5) {
                ForEach(Category.allCases, id: \.self) { category in
                    if category != .income {
                        getCategoryView(for: category)
                    }
                }
            }
            .padding()
        }
    }

    private func getCategoryView(for category: Category) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(category.tintColor)
                    .frame(width: 28, height: 28)

                category.icon
                    .foregroundColor(.white)
            }

            Spacer()

            Text("$\(String(format: "%.2f", totalsByCategory[category] ?? 0.0))")
        }
        .padding(.horizontal)
        .border(Color.blue, width: selectedCategory == category ? 1 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCategory = category == selectedCategory ? nil : category
        }
    }
}


