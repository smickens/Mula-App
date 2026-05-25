//
//  IncomeView.swift
//  Mula
//
//  Created by Codex on 5/21/26.
//

import SwiftUI

struct IncomeView: View {
    @Environment(DataManager.self) private var dataManager
    
    @State private var selectedDate: Date = Date()

    private enum Layout {
        static let spacing: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let chartHeight: CGFloat = 360
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            HStack {
                Text("Income")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                DatePeriodSelector(selectedDate: $selectedDate, granularity: .year)
            }

            incomeChart

            // TODO: can more of this styling be shared with the TrendsView summaryGrid. could something be factored out for that base shape maybe?
            summaryGrid

            Spacer()
        }
        .padding()
    }
}

private extension IncomeView {
    var incomeChart: some View {
        StackedBarChart(
            data: viewData.chartSegments,
            xAxisLabel: "Month",
            yAxisLabel: "Income",
            categoryLabel: "Category",
            colorScale: incomeCategoryColors,
            date: \.monthStart,
            value: \.total,
            category: \.category.displayName
        )
        .frame(maxWidth: .infinity, minHeight: Layout.chartHeight)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(Layout.cornerRadius)
    }

    var summaryGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: Layout.spacing, verticalSpacing: Layout.spacing) {
            GridRow {
                SummaryCardView(title: "Average Monthly Income") {
                    Text(viewData.averageMonthlyIncome.toCurrency())
                        .font(.title2)
                        .fontWeight(.bold)
                }

                SummaryCardView(title: "Total Income") {
                    Text(viewData.totalIncome.toCurrency())
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            GridRow {
                SummaryCardView(title: "Highest Month") {
                    Text(viewData.highestMonth?.monthLabel ?? "N/A")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text((viewData.highestMonth?.total ?? 0).toCurrency())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                SummaryCardView(title: "Top Category") {
                    if let topCategory = viewData.topCategory {
                        HStack {
                            Image(systemName: topCategory.category.iconName)
                            Text(topCategory.category.displayName)
                        }
                        .font(.title2)
                        .fontWeight(.bold)

                        Text(topCategory.total.toCurrency())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }

    var viewData: ViewData {
        let months = monthsInSelectedYear()
        let incomeTransactions = dataManager.transactions.filter { $0.kind.isIncome }
        let chartSegments = chartSegments(for: incomeTransactions, months: months)
        let monthlySummaries = monthlySummaries(for: chartSegments, months: months)
        let totalIncome = chartSegments.reduce(0) { $0 + Decimal($1.total) }
        let topCategory = topCategory(in: chartSegments)

        return ViewData(
            chartSegments: chartSegments,
            monthlySummaries: monthlySummaries,
            totalIncome: totalIncome,
            averageMonthlyIncome: totalIncome / Decimal(months.count),
            highestMonth: monthlySummaries.max { $0.total < $1.total },
            topCategory: topCategory
        )
    }

    var incomeCategoryColors: KeyValuePairs<String, Color> {
        [
            IncomeCategory.job.displayName: IncomeCategory.job.baseColor,
            IncomeCategory.refund.displayName: IncomeCategory.refund.baseColor,
            IncomeCategory.dividend.displayName: IncomeCategory.dividend.baseColor,
            IncomeCategory.interest.displayName: IncomeCategory.interest.baseColor,
            IncomeCategory.other.displayName: IncomeCategory.other.baseColor
        ]
    }

    func monthsInSelectedYear() -> [Date] {
        let calendar = Calendar.current
        let selectedYear = calendar.component(.year, from: selectedDate)

        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: selectedYear, month: month, day: 1))
        }
    }

    func chartSegments(for transactions: [Transaction], months: [Date]) -> [ChartSegment] {
        let calendar = Calendar.current
        let monthStarts = Set(months)
        var totals: [SegmentKey: Decimal] = [:]

        for transaction in transactions {
            guard let monthStart = calendar.dateInterval(of: .month, for: transaction.date)?.start,
                  monthStarts.contains(monthStart),
                  case .income(let category) = transaction.kind else {
                continue
            }

            let key = SegmentKey(monthStart: monthStart, category: category)
            totals[key, default: 0] += transaction.amount
        }

        return totals.map { key, total in
            ChartSegment(
                monthStart: key.monthStart,
                category: key.category,
                total: (total as NSDecimalNumber).doubleValue
            )
        }
        .sorted {
            if $0.monthStart == $1.monthStart {
                return $0.category.displayName < $1.category.displayName
            }
            return $0.monthStart < $1.monthStart
        }
    }

    func monthlySummaries(for chartSegments: [ChartSegment], months: [Date]) -> [MonthlySummary] {
        months.map { monthStart in
            let total = chartSegments
                .filter { $0.monthStart == monthStart }
                .reduce(0) { $0 + Decimal($1.total) }

            return MonthlySummary(
                monthStart: monthStart,
                monthLabel: monthLabel(for: monthStart),
                total: total
            )
        }
    }

    func topCategory(in chartSegments: [ChartSegment]) -> CategorySummary? {
        let totals = chartSegments.reduce(into: [IncomeCategory: Decimal]()) { result, segment in
            result[segment.category, default: 0] += Decimal(segment.total)
        }

        guard let top = totals.max(by: { $0.value < $1.value }) else {
            return nil
        }

        return CategorySummary(category: top.key, total: top.value)
    }

    func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

private struct SegmentKey: Hashable {
    let monthStart: Date
    let category: IncomeCategory
}

private struct ChartSegment: Identifiable {
    let monthStart: Date
    let category: IncomeCategory
    let total: Double

    var id: String {
        "\(monthStart.timeIntervalSince1970)-\(category.id)"
    }
}

private struct MonthlySummary {
    let monthStart: Date
    let monthLabel: String
    let total: Decimal
}

private struct CategorySummary {
    let category: IncomeCategory
    let total: Decimal
}

private struct ViewData {
    let chartSegments: [ChartSegment]
    let monthlySummaries: [MonthlySummary]
    let totalIncome: Decimal
    let averageMonthlyIncome: Decimal
    let highestMonth: MonthlySummary?
    let topCategory: CategorySummary?
}
