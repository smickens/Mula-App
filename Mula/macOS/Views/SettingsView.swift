//
//  SettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 6/3/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query var budgets: [Budget]
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Text("Montly Budget")
                .font(.callout)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(Category.allCases, id: \.self) { category in
                    HStack {
                        if category != .income {
                            let budget = budget(for: category)
                            
                            ZStack {
                                Circle()
                                    .fill(budget.category.tintColor)
                                    .frame(width: 28, height: 28)

                                budget.category.icon
                                    .foregroundColor(.white)
                            }
                            
//                            Text("\(budget.category.name):")
                            
                            TextField("", value: Bindable(budget).target, format: .currency(code: "USD"))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
                
            Text("Total: ") + Text(totalBudget, format: .currency(code: "USD"))
            
            Spacer()
        }
        .frame(width: 360, height: 280)
    }
    
    private func budget(for category: Category) -> Budget {
        if let budget = budgets.first(where: { $0.category == category }) {
            return budget
        }
        
        let newBudget = Budget(category: category, target: 0)
        modelContext.insert(newBudget)
        return newBudget
    }
    
    private var totalBudget: Double {
        return budgets.reduce(0) { $0 + $1.target }
    }
}
