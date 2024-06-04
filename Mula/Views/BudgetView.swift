//
//  BudgetView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/17/24.
//

import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query(sort: \Budget.categoryTitle, order: .forward) var budgets: [Budget]
    let totalsByCategory: [Category: Double]

    var body: some View {
        VStack {
            Text("Total Budget: $\(String(format: "%.2f", totalBudget))")

            ForEach(budgets, id: \.category) { budget in
                HStack {
                    ZStack {
                        Circle()
                            .fill(budget.category.tintColor)
                            .frame(width: 28, height: 28)

                        budget.category.icon
                            .foregroundColor(.white)
                    }

                    Spacer()

                    let percentage = usedBudgetPercentage(for: budget)

                    // TODO: custom progress view to highlight over-budget portion
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressView(value: min(percentage, 1.0))
                            .progressViewStyle(.linear)
                            .frame(height: 20)
                        
                        Text("\(Int(percentage * 100))%")
                            .padding(.top, 8)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", budget.target))")
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func usedBudgetPercentage(for budget: Budget) -> Double {
        if budget.target != 0.0 {
            return (totalsByCategory[budget.category] ?? 0.0) / budget.target
        }
        return (totalsByCategory[budget.category] ?? 0.0) > 0 ? 1.0 : 0.0
    }

    private var totalBudget: Double {
        return budgets.reduce(0) { $0 + $1.target }
    }
}
