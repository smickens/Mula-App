//
//  SpendingBarChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI
import Charts

struct SpendingBarChartView: View {
    let spendingByCategory: [DataManager.CategorySpending]

    var body: some View {
        Chart(spendingByCategory) { categorySpending in
            BarMark(
                x: .value("Category", categorySpending.category.displayName),
                y: .value("Amount", categorySpending.total)
            )
            .foregroundStyle(categorySpending.category.tintColor)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
            }
        }
        .frame(height: 250)
    }
}
