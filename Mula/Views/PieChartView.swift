//
//  PieChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/13/24.
//

import SwiftUI

// TODO: on tap gesture of pie slice or category, it should filter to only that category

struct PieChartView: View {
    let totals: [Double]
    let categories: [Category]

    var body: some View {
        ZStack {
            // Pie chart slices
            ForEach(0..<totals.count, id: \.self) { index in
                PieChartSlice(angles: angles(for: index))
                    .fill(categories[index].tintColor)
            }

            Circle()
                .foregroundStyle(.windowBackground)
                .frame(width: 88, height: 88)

//            Text(totalSpent, format: .currency(code: "USD"))
//                .font(.title2)
//                .fontWeight(.medium)
        }
        .padding()
    }

    private var totalSpent: Double {
        return totals.reduce(0.0, +)
    }

    private func angles(for index: Int) -> (Angle, Angle) {
        let startAngle = index == 0 ? .zero : angles(for: index - 1).1
        let angle = 2.0 * .pi * totals[index] / totalSpent
        return (startAngle, startAngle + Angle(radians: angle))
    }
}

struct PieChartSlice: Shape {
    var angles: (Angle, Angle)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: angles.0, endAngle: angles.1, clockwise: false)
        path.closeSubpath()

        return path
    }
}

//#Preview {
//    SummaryView(expenses: ExpenseViewModel().expenses)
//}
