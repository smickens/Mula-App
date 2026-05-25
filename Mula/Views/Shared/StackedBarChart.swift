//
//  StackedBarChart.swift
//  Mula
//
//  Created by Codex on 5/25/26.
//

import Charts
import SwiftUI

struct StackedBarChart<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    let data: Data
    let xAxisLabel: String
    let yAxisLabel: String
    let categoryLabel: String
    let colorScale: KeyValuePairs<String, Color>
    let date: (Data.Element) -> Date
    let value: (Data.Element) -> Double
    let category: (Data.Element) -> String

    var body: some View {
        Chart(data) { element in
            BarMark(
                x: .value(xAxisLabel, date(element), unit: .month),
                y: .value(yAxisLabel, value(element))
            )
            .foregroundStyle(by: .value(categoryLabel, category(element)))
        }
        .chartForegroundStyleScale(colorScale)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { axisValue in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let amount = axisValue.as(Double.self) {
                        Text(Decimal(amount).toCurrency())
                    }
                }
            }
        }
    }
}
