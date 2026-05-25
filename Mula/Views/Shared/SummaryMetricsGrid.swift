//
//  SummaryMetricsGrid.swift
//  Mula
//
//  Created by Codex on 5/25/26.
//

import SwiftUI

struct SummaryMetric: Identifiable {
    let id = UUID()
    let title: String
    let primaryText: String
    let secondaryText: String?
    let iconName: String?
    let primaryColor: Color

    init(
        title: String,
        primaryText: String,
        secondaryText: String? = nil,
        iconName: String? = nil,
        primaryColor: Color = .primary
    ) {
        self.title = title
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.iconName = iconName
        self.primaryColor = primaryColor
    }
}

struct SummaryMetricsGrid: View {
    let metrics: [SummaryMetric]
    let spacing: CGFloat

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: spacing),
                GridItem(.flexible(), spacing: spacing)
            ],
            alignment: .leading,
            spacing: spacing
        ) {
            ForEach(metrics) { metric in
                SummaryMetricCard(metric: metric)
            }
        }
    }
}

private struct SummaryMetricCard: View {
    let metric: SummaryMetric

    var body: some View {
        SummaryCardView(title: metric.title) {
            HStack {
                if let iconName = metric.iconName {
                    Image(systemName: iconName)
                }

                Text(metric.primaryText)
            }
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(metric.primaryColor)

            if let secondaryText = metric.secondaryText {
                Text(secondaryText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
