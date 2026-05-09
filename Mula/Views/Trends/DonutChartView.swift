//
//  DonutChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct DonutChartView: View {
    private enum Layout {
        static let size: CGFloat = 300
        static let segmentGapDegrees: Double = 1.5
        static let segmentThickness: CGFloat = 40
        static let titleSpacing: CGFloat = 6
        static let valueFontSize: CGFloat = 28
        static let startAngle: Double = -90
    }

    let spendingByCategory: [DataManager.CategorySpending]
    let totalSpending: Decimal

    var body: some View {
        ZStack {
            ForEach(segments) { segment in
                DonutSegmentView(
                    segment: segment,
                    thickness: Layout.segmentThickness
                )
            }

            VStack(spacing: Layout.titleSpacing) {
                Text("Total Spending")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(totalSpending.toCurrency())
                    .font(.system(size: Layout.valueFontSize, weight: .semibold))
            }
        }
        .frame(width: Layout.size, height: Layout.size)
    }

    private var segments: [DonutSegment] {
        guard totalSpending != 0 else { return [] }

        let totalValue = decimalValue(totalSpending)
        var currentStartAngle = Layout.startAngle

        return spendingByCategory
            .sorted { $0.total > $1.total }
            .compactMap { item in
                let segmentDegrees = degrees(for: item.total, totalValue: totalValue)
                defer { currentStartAngle += segmentDegrees }

                // Prevents very small segments from displaying around the whole ring
                guard segmentDegrees > Layout.segmentGapDegrees else {
                    return nil
                }

                return DonutSegment(
                    id: segmentID(for: item),
                    startAngle: currentStartAngle,
                    endAngle: currentStartAngle + segmentDegrees - Layout.segmentGapDegrees,
                    color: item.category.baseColor
                )
            }
    }

    private func degrees(for amount: Decimal, totalValue: Double) -> Double {
        guard totalValue > 0 else {
            return 0
        }
        return (decimalValue(amount) / totalValue) * 360
    }

    private func decimalValue(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    private func segmentID(for item: DataManager.CategorySpending) -> String {
        "\(item.category.id)-\(decimalValue(item.total))"
    }
}

private struct DonutSegment: Identifiable {
    let id: String
    let startAngle: Double
    let endAngle: Double
    let color: Color
}

private struct DonutSegmentView: View {
    let segment: DonutSegment
    let thickness: CGFloat

    var body: some View {
        GeometryReader { geometry in
            segmentPath(in: geometry.frame(in: .local))
                .fill(segment.color)
        }
    }

    private func segmentPath(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width / 2
        let innerRadius = outerRadius - thickness
        let startAngle = Angle.degrees(segment.startAngle)
        let endAngle = Angle.degrees(segment.endAngle)

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
