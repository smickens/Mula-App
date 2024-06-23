//
//  PieChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/13/24.
//

import SwiftUI
import Charts

struct CategoryCount {
    var category: Category
    var total: Double
}

struct PieChartView: View {
    @Binding var selectedCategory: Category?
    let data: [CategoryCount]
    // TODO: take in this value
    let totalSpent: Double

    init(selectedCategory: Binding<Category?>, totalsByCategory: [Category: Double]) {
        _selectedCategory = selectedCategory
        var counts: [CategoryCount] = []
        var t = 0.0
        totalsByCategory.sorted(by: { $0.value < $1.value }).forEach { category, total in
            guard total > 0 else { return }
            counts.append(CategoryCount(category: category, total: total))
            t += total
        }
        data = counts
        totalSpent = t
        print(data)
    }

    var body: some View {
        Chart(data, id: \.category) { item in
            SectorMark(
                angle: .value("Total", item.total),
                innerRadius: .ratio(0.6)
//                angularInset: 2
            )
//            .cornerRadius(5)
            .foregroundStyle(item.category.tintColor)
            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1 : 0.5)
        }
        .chartLegend(.hidden)
//        .chartAngleSelection(value: $selectedAngle)
        .scaledToFit()
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                if let anchor = chartProxy.plotFrame {
                    let frame = geometry[anchor]
                    Text("\(totalSpent)")
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }

        .padding()
    }
}
