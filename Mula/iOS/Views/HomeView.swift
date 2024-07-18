//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedMonth: String = Date().month

    @State private var expensesForMonth: [Expense]
    @State private var fixed: Double
    @State private var spending: Double
    @State private var saving: Double
    @State private var investment: Double

    init() {
        expensesForMonth = DataManager.shared.expenses
        fixed = DataManager.shared.total(for: Date().month, in: .fixed)
        spending = DataManager.shared.total(for: Date().month, in: .spending)
        saving = DataManager.shared.total(for: Date().month, in: .saving)
        investment = DataManager.shared.total(for: Date().month, in: .investment)
    }

    var body: some View {
        ScrollView {
            HeaderView(title: "Mula", selectedMonth: $selectedMonth)

            Grid {
                GridRow {
                    TileView(title: "Fixed", icon: "grid", tint: .cyan, amount: $fixed, budget: .constant(3150))

                    TileView(title: "Spending", icon: "tag.fill", tint: .pink, amount: $spending, budget: .constant(500))
                }

                GridRow {
                    TileView(title: "Savings", icon: "bolt.fill", tint: .green, amount: $saving, budget: .constant(500))

                    TileView(title: "Investments", icon: "hourglass", tint: .indigo, amount: $investment, budget: .constant(500))
                }

                GridRow {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .frame(height: 170.0)
                            .foregroundStyle(.secondary.opacity(0.1))

                        VStack {
                            Text("Overview")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ChartView(expenses: expensesForMonth)
                        }
                        .padding()
                    }
                    .gridCellColumns(2)
                }
            }
        }
        .padding()
//                .navigationTitle("Mula")
        .navigationBarHidden(true)
//                .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .onChange(of: selectedMonth) { _, newValue in
            expensesForMonth = DataManager.shared.expenses(for: selectedMonth)
            fixed = DataManager.shared.total(for: selectedMonth, in: .fixed)
            spending = DataManager.shared.total(for: selectedMonth, in: .spending)
            saving = DataManager.shared.total(for: selectedMonth, in: .saving)
            investment = DataManager.shared.total(for: selectedMonth, in: .investment)
        }
    }

    
}

#Preview {
    HomeView()
}
