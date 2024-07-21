//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedMonth: String

    @State private var expensesForMonth: [Expense] = []
    @State private var incomesForMonth: [Income] = []

    @State private var fixed: Double = 0.0
    @State private var spending: Double = 0.0
    @State private var saving: Double = 0.0
    @State private var investment: Double = 0.0
    @State private var income: Double = 0.0

    var body: some View {
        ScrollView {
            Grid(alignment: .top) {
                GridRow {
                    HeaderView(title: "Mula", selectedMonth: $selectedMonth)
                }
                .gridCellColumns(2)

                GridRow {
                    TileView(title: "Fixed", icon: "grid", tint: .cyan, amount: $fixed, budget: .constant(3150))

                    TileView(title: "Spending", icon: "tag.fill", tint: .pink, amount: $spending, budget: .constant(500))
                }

                GridRow {
                    TileView(title: "Savings", icon: "bolt.fill", tint: .green, amount: $saving, budget: .constant(500))

                    TileView(title: "Investments", icon: "hourglass", tint: .indigo, amount: $investment, budget: .constant(500))
                }

                GridRow {
                    VStack {
                        Text("Overview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ChartView(transactions: expensesForMonth + incomesForMonth)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(backgroundCornerRadius)
                    .gridCellColumns(2)
                }

                GridRow {
                    RowView(iconName: "arrow.up", title: "Income:", color: .green) {
                        Text(income, format: .currency(code: "USD"))
                            .font(.body)
                    }
                    .gridCellColumns(2)
                }

                ForEach(Category.allCases) { category in
                    GridRow {
                        RowView(iconName: category.iconName, title: category.name, color: category.tintColor) {
                            Text(15.00, format: .currency(code: "USD"))
                                .font(.body)
                        }
                        .gridCellColumns(2)
                    }
                }
            }
        }
        .padding()
//        .navigationTitle("Mula")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .scrollIndicators(.hidden)
        .onAppear {
            refreshData(for: selectedMonth)
        }
        .onChange(of: selectedMonth) { _, newValue in
            refreshData(for: newValue)
        }
    }

    func refreshData(for month: String = Date().month) {
        expensesForMonth = DataManager.shared.expenses(for: month)
        incomesForMonth = DataManager.shared.incomes(for: month)
        fixed = DataManager.shared.total(for: month, in: .fixed)
        spending = DataManager.shared.total(for: month, in: .spending)
        saving = DataManager.shared.total(for: month, in: .saving)
        investment = DataManager.shared.total(for: month, in: .investment)
        income = DataManager.shared.totalIncome(for: month)
    }

}

#Preview {
    HomeView(selectedMonth: .constant("May"))
}
