//
//  ChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 6/23/24.
//

import SwiftUI
import Charts

struct ChartData: Identifiable {
    let id = UUID()
    let value: Double
    let date: Date
}

struct ChartView: View {
    let data: [ChartData]
    let color: Color = .gray

    init(expenses: [Expense]) {
        var aggregated: [ChartData] = []
        var currentValue = 0.0
        var prevDate: Date? = nil
        expenses.sorted(by: { $0.date < $1.date }).forEach { expense in
            currentValue += expense.amount
            if prevDate == nil || prevDate != expense.date {
                aggregated.append(ChartData(
                    value: currentValue,
                    date: expense.date)
                )
                prevDate = expense.date
            }
        }
        self.data = aggregated
    }

    var body: some View {
        Chart(data) {
            // could use multiple line marks to break out by category

            LineMark(
                x: .value("Month", $0.date),
                y: .value("Amount", $0.value)
            )
            .interpolationMethod(.catmullRom(alpha: 1.0))

            AreaMark(
                x: .value("Month", $0.date),
                y: .value("Amount", $0.value)
            )
            .interpolationMethod(.catmullRom(alpha: 1.0))
            .foregroundStyle(areaBackground)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits), centered: true)
            }
        }
        .foregroundStyle(color)
    }

    private var areaBackground: Gradient {
        return Gradient(colors: [color.opacity(0.1), color.opacity(0.3)])
    }
}
