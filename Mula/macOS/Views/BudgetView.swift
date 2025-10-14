//
//  BudgetView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/17/24.
//

import SwiftUI

struct BudgetView: View {
    var budgets: [Budget]
    let totalsByCategory: [Category: Double]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(Category.allCases, id: \.self) { category in
                if let budget = getBudget(for: category) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(budget.category.tintColor)
                                .frame(width: 28, height: 28)

                            Image(systemName: budget.category.iconName)
                                .foregroundColor(.white)
                        }

                        ProgressBar(target: budget.target, totalSpent: totalsByCategory[budget.category] ?? 0.0, barColor: budget.category.tintColor)
                    }
                }
            }
            
//            Text("Spent: ") + Text(totalSpent, format: .currency(code: "USD"))
            
            Text("Budget: ") + Text(totalBudget, format: .currency(code: "USD"))
            
            HStack {
                ZStack {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 28, height: 28)

                    Image(systemName: "equal")
                        .foregroundColor(.white)
                }

                ProgressBar(target: totalBudget, totalSpent: totalSpent, barColor: .secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private func getBudget(for category: Category) -> Budget? {
//        guard category != .income else { return nil }
        return budgets.first(where: { $0.category == category })
    }
    
    private var totalSpent: Double {
        return totalsByCategory
//            .filter({ $0.key != .income } )
            .reduce(0.0) { $0 + $1.value }
    }

    private var totalBudget: Double {
        return budgets.reduce(0) { $0 + $1.target }
    }
}
