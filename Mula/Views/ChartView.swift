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
    let value: Decimal
    let date: Date
}

struct ChartView: View {
    let data: [ChartData]
    let color: Color = .gray

    init(transactions: [Transaction]) {
        var aggregated: [ChartData] = []
        var currentValue: Decimal = 0.0
        var prevDate: Date? = nil
        transactions.sorted(by: { $0.date < $1.date }).forEach { transaction in
            let date = transaction.date
            currentValue += transaction.amount
            if prevDate == nil || prevDate != date {
                aggregated.append(ChartData(
                    value: currentValue,
                    date: date)
                )
                prevDate = date
            }
        }
        self.data = aggregated
    }

    var body: some View {
        // TODO: use up the same amount of height when empty
        if data.count == 0 {
            Text("No transactions")
        } else {
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
    }

    private var areaBackground: Gradient {
        return Gradient(colors: [color.opacity(0.1), color.opacity(0.3)])
    }
}
