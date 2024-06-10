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
        VStack(spacing: 10) {
            ForEach(Category.allCases, id: \.self) { category in
                if let budget = getBudget(for: category) {
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

                        Text(budget.target, format: .currency(code: "USD"))
                    }
                    .padding(.horizontal)
                }
            }
            
            Text("Total Spent: ") + Text(totalSpent, format: .currency(code: "USD"))
            
            Text("Total Budget: ") + Text(totalBudget, format: .currency(code: "USD"))
        }
    }
    
    private func getBudget(for category: Category) -> Budget? {
        guard category != .income else { return nil }
        return budgets.first(where: { $0.category == category })
    }
    
    private func usedBudgetPercentage(for budget: Budget) -> Double {
        if budget.target != 0.0 {
            return (totalsByCategory[budget.category] ?? 0.0) / budget.target
        }
        return (totalsByCategory[budget.category] ?? 0.0) > 0 ? 1.0 : 0.0
    }
    
    private var totalSpent: Double {
        return totalsByCategory.filter({ $0.key != .income } ).reduce(0.0) { $0 + $1.value }
    }

    private var totalBudget: Double {
        return budgets.reduce(0) { $0 + $1.target }
    }
}
