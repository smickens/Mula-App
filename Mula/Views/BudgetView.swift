//
//  BudgetView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/17/24.
//

import SwiftUI

struct Budget {
    let category: Category
    let target: Double
}

struct BudgetView: View {
    let totalsByCategory: [Category: Double]
    let budgets: [Budget] = [
        .init(category: .housing, target: 3100.00),
        .init(category: .food, target: 250.00),
        .init(category: .shopping, target: 200.00),
        .init(category: .transportation, target: 100.00),
        .init(category: .entertainment, target: 100.00),
        .init(category: .misc, target: 50.00),
    ]

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

                    let usedBudgetPercentage = (totalsByCategory[budget.category] ?? 0.0) / budget.target

                    // TODO: custom progress view to highlight over-budget portion
                    VStack(alignment: .leading, spacing: 0) {
                        ProgressView(value: min(usedBudgetPercentage, 1.0))
                            .progressViewStyle(.linear)
                            .frame(height: 20)
                        
                        Text("\(Int(usedBudgetPercentage * 100))%")
                            .padding(.top, 8)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", budget.target))")
                }
            }
        }
    }

    private var totalBudget: Double {
        return budgets.reduce(0) { $0 + $1.target }
    }
}

//#Preview {
//    BudgetView()
//}
