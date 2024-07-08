//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 6/23/24.
//

import SwiftUI

struct HomeView: View {
    let expenses: [Expense]

    @State private var selectedMonth: String = Date().month

    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        VStack(alignment: .leading) {
            Text("Spending in May")
                .font(.headline)

            Text("$5,000")
                .font(.largeTitle)

            ChartView(expenses: expensesForMonth)

            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text(month)
                }
            }

            ForEach(Category.allCases, id: \.self) { category in
//                if let total = getTotalSpent(for: category) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(category.tintColor)
                                .frame(width: 28, height: 28)

                            category.icon
                                .foregroundColor(.white)
                        }

                        Text(category.name)

                        Spacer()

                        Text("$15.98")

//                        ProgressBar(target: budget.target, totalSpent: totalsByCategory[budget.category] ?? 0.0, barColor: budget.category.tintColor)
                    }
//                }
            }
        }
    }

    private var expensesForMonth: [Expense] {
        return expenses.filter { $0.date.month == selectedMonth }
    }
}
