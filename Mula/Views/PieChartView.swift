//
//  PieChartView.swift
//  Mula
//
//  Created by Shanti Mickens on 3/13/24.
//

import SwiftUI
import Charts

struct CategoryCount {
    var category: any TransactionCategoryProtocol
    var total: Decimal
}

struct PieChartView: View {
    @Binding var selectedCategory: (any TransactionCategoryProtocol)?
    let data: [CategoryCount]
    let totalSpent: Decimal

    init(selectedCategory: Binding<(any TransactionCategoryProtocol)?>, totalsByCategory: [(any TransactionCategoryProtocol, Decimal)]) {
        _selectedCategory = selectedCategory

        var counts: [CategoryCount] = []
        var t: Decimal = 0.0

        totalsByCategory.sorted(by: { $0.1 < $1.1 }).forEach { category, total in
            guard total < 0 else { return } // only spending
            counts.append(CategoryCount(category: category, total: total))
            t += total
        }

        self.data = counts
        self.totalSpent = t
    }

    var body: some View {
        Chart(data, id: \.category.id) { item in
            SectorMark(
                angle: .value("Total", item.total),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(item.category.baseColor)
            .opacity(selectedCategory == nil || selectedCategory?.id == item.category.id ? 1 : 0.5)
        }
        .chartLegend(.hidden)
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
    }
}
