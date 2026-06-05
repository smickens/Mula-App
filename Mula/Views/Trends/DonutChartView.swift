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
        static let selectedSegmentOffset: CGFloat = 8
        static let titleSpacing: CGFloat = 6
        static let valueFontSize: CGFloat = 28
        static let startAngle: Double = -90
    }

    let spendingByCategory: [DataManager.CategorySpending]
    let totalSpending: Decimal
    let spendingTitle: String
    @Binding var selectedCategoryId: String?

    var body: some View {
        ZStack {
            ForEach(segments) { segment in
                DonutSegmentView(
                    segment: segment,
                    thickness: Layout.segmentThickness,
                    isSelected: selectedCategoryId == segment.categoryId,
                    selectedOffset: Layout.selectedSegmentOffset
                )
            }

            VStack(spacing: Layout.titleSpacing) {
                Text(spendingTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(totalSpending.toCurrency())
                    .font(.system(size: Layout.valueFontSize, weight: .semibold))
            }
        }
        .frame(width: Layout.size, height: Layout.size)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    selectSegment(at: value.location)
                }
        )
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
                    categoryId: item.category.id,
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

    private func selectSegment(at location: CGPoint) {
        let center = CGPoint(x: Layout.size / 2, y: Layout.size / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        let outerRadius = Layout.size / 2 + Layout.selectedSegmentOffset
        let innerRadius = outerRadius - Layout.segmentThickness - Layout.selectedSegmentOffset

        guard radius >= innerRadius, radius <= outerRadius else {
            return
        }

        let angle = normalizedAngle(Double(atan2(dy, dx)) * 180 / .pi)

        guard let segment = segments.first(where: { $0.contains(angle: angle) }) else {
            return
        }

        if selectedCategoryId == segment.categoryId {
            selectedCategoryId = nil
        } else {
            selectedCategoryId = segment.categoryId
        }
    }

    private func normalizedAngle(_ angle: Double) -> Double {
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
}

private struct DonutSegment: Identifiable {
    let id: String
    let categoryId: String
    let startAngle: Double
    let endAngle: Double
    let color: Color

    var midAngle: Double {
        (startAngle + endAngle) / 2
    }

    func contains(angle: Double) -> Bool {
        let start = normalized(startAngle)
        let end = normalized(endAngle)

        if start <= end {
            return angle >= start && angle <= end
        }

        return angle >= start || angle <= end
    }

    private func normalized(_ angle: Double) -> Double {
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
}

private struct DonutSegmentView: View {
    let segment: DonutSegment
    let thickness: CGFloat
    let isSelected: Bool
    let selectedOffset: CGFloat

    var body: some View {
        DonutSegmentShape(
            segment: segment,
            thickness: thickness,
            expansion: isSelected ? selectedOffset : 0
        )
        .fill(segment.color)
        .shadow(color: isSelected ? segment.color.opacity(0.35) : .clear, radius: isSelected ? 6 : 0)
        .animation(.spring(response: 0.36, dampingFraction: 0.82), value: isSelected)
    }
}

private struct DonutSegmentShape: Shape {
    let segment: DonutSegment
    let thickness: CGFloat
    var expansion: CGFloat

    var animatableData: CGFloat {
        get { expansion }
        set { expansion = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseOuterRadius = rect.width / 2
        let outerRadius = baseOuterRadius + expansion
        let innerRadius = baseOuterRadius - thickness
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
