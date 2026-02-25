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
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Categories")
                    .font(.headline)
                Spacer()
                Text("Total Spending")
                    .font(.headline)
            }

            ForEach(spendingByCategory) { categorySpending in
                CategoryListRow(
                    categorySpending: categorySpending,
                    totalSpending: totalSpending
                )
            }

            Spacer()
        }
        .padding()
    }
}
