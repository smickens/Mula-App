//
//  CategoryListRow.swift
//  Mula
//
//  Created by Shanti Mickens on 2/24/26.
//

import SwiftUI

struct CategoryListRow: View {
    let categorySpending: DataManager.CategorySpending
    let totalSpending: Decimal

    @State private var isHovering = false

    private var percentageValue: Double {
        guard totalSpending != 0 else { return 0 }
        return (categorySpending.total as NSDecimalNumber).doubleValue /
               (totalSpending as NSDecimalNumber).doubleValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Image(systemName: categorySpending.category.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(categorySpending.category.baseColor)

                Text(categorySpending.category.displayName)
                    .font(.callout)

                Spacer()

                Text(categorySpending.total.toCurrency())
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            CategoryProgressBar(
                percentage: percentageValue,
                color: categorySpending.category.baseColor,
                height: 15
            )
        }
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
