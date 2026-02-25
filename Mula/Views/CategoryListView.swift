//
//  CategoryListView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct CategoryListView: View {
    let spendingByCategory: [DataManager.CategorySpending]
    let totalSpending: Decimal

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Categories")
                    .font(.headline)
                Spacer()
                Text("Total Spending")
                    .font(.headline)
            }
            .padding(.bottom, 8)
            
            ForEach(spendingByCategory) { categorySpending in
                CategoryListRow(
                    categorySpending: categorySpending,
                    totalSpending: totalSpending
                )
            }
        }
    }
}

struct CategoryListRow: View {
    let categorySpending: DataManager.CategorySpending
    let totalSpending: Decimal

    private var percentage: Decimal {
        guard totalSpending != 0 else { return 0 }

        var result = (categorySpending.total / totalSpending) * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, 0, .plain) // 0 decimal places
        return rounded
    }

    var body: some View {
        HStack {
            Image(systemName: categorySpending.category.iconName)
                .font(.system(size: 16))
                .foregroundColor(categorySpending.category.baseColor)
                .frame(width: 25, height: 25)
                .background(categorySpending.category.baseColor.opacity(0.1))
                .cornerRadius(4)
            
            Text(categorySpending.category.displayName)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(categorySpending.total.toCurrency())
                    .fontWeight(.semibold)
                
                HStack {
                    Text("\((percentage as NSDecimalNumber).intValue)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(
                        value: (categorySpending.total as NSDecimalNumber).doubleValue,
                        total: (totalSpending as NSDecimalNumber).doubleValue
                    )
                        .progressViewStyle(.linear)
                        .frame(width: 50)
                        .tint(categorySpending.category.baseColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
