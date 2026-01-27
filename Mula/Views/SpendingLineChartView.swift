//
//  SpendingLineChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI
import Charts

struct SpendingLineChartView: View {
    let spendingByMonth: [DataManager.MonthlySpending]

    var body: some View {
        Chart {
            ForEach(spendingByMonth) { monthData in
                ForEach(monthData.spendingByCategory.keys.sorted(by: { $0.displayName < $1.displayName }), id: \.self) { category in
                    LineMark(
                        x: .value("Month", monthData.date, unit: .month),
                        y: .value("Amount", monthData.spendingByCategory[category]!)
                    )
                    .foregroundStyle(by: .value("Category", category.displayName))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Month", monthData.date, unit: .month),
                        y: .value("Amount", monthData.spendingByCategory[category]!)
                    )
                    .foregroundStyle(by: .value("Category", category.displayName))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .chartForegroundStyleScale(domain: TransactionCategory.allCases.map { $0.displayName },
                                   range: TransactionCategory.allCases.map { $0.tintColor })
        .frame(height: 250)
    }
}
