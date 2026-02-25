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
            let segments: [(start: Double, end: Double, color: Color)] = {
                var result: [(Double, Double, Color)] = []
                var currentStart: Double = -90

                for item in sortedSpending {
                    let percentage = (totalSpending != 0) ? (item.total / totalSpending) : 0
                    let end = currentStart + (Double(truncating: percentage as NSNumber) * 360)
                    result.append((start: currentStart, end: end, color: item.category.baseColor))
                    currentStart = end
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
            VStack {
                Text("Total Spending")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(totalSpending.toCurrency())
                    .font(.title)
                    .fontWeight(.bold)
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
        DonutSegmentShape(startAngle: startAngle, endAngle: endAngle)
            .stroke(color, style: StrokeStyle(lineWidth: 50, lineCap: .butt))
    }
}

struct DonutSegmentShape: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2 - 25 // 25 is half of the lineWidth
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}
