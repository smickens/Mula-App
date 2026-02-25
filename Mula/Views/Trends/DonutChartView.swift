//
//  DonutChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct DonutChartView: View {
    let spendingByCategory: [DataManager.CategorySpending]
    let totalSpending: Decimal

    var body: some View {
        ZStack {
            let sortedSpending = spendingByCategory.sorted { $0.total > $1.total }

            // Precompute start/end angles
            let gapDegrees: Double = 1.5

            let segments: [(start: Double, end: Double, color: Color)] = {
                var result: [(Double, Double, Color)] = []
                var currentStart: Double = -90

                for item in sortedSpending {
                    let percentage = (totalSpending != 0)
                        ? (item.total as NSDecimalNumber).doubleValue /
                          (totalSpending as NSDecimalNumber).doubleValue
                        : 0

                    let degrees = percentage * 360
                    let adjustedEnd = currentStart + degrees - gapDegrees

                    if degrees > 0 {
                        result.append((
                            start: currentStart,
                            end: adjustedEnd,
                            color: item.category.baseColor
                        ))
                    }

                    currentStart += degrees
                }

                return result
            }()


            // Render segments
            ForEach(0..<segments.count, id: \.self) { index in
                let segment = segments[index]
                DonutSegment(
                    startAngle: .degrees(segment.start),
                    endAngle: .degrees(segment.end),
                    color: segment.color
                )
            }

            // Center text
            VStack(spacing: 6) {
                Text("Total Spending")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(totalSpending.toCurrency())
                    .font(.system(size: 28, weight: .semibold))
            }
        }
        .frame(width: 300, height: 300)
    }
}

struct DonutSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        DonutSegmentShape(
            startAngle: startAngle,
            endAngle: endAngle,
            thickness: 40
        )
        .fill(color)
    }
}

struct DonutSegmentShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width / 2
        let innerRadius = outerRadius - thickness

        var path = Path()

        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        path.closeSubpath()

        return path
    }
}
