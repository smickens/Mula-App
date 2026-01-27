//
//  TrendsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI



struct TrendsView: View {

    @Environment(DataManager.self) private var dataManager

    @State private var selectedTimeRange: TimeRange = .oneMonth



    enum TimeRange: String, CaseIterable {

        case oneMonth = "1M"

        case threeMonths = "3M"

        case sixMonths = "6M"

        case oneYear = "1Y"



        var arugment: String {

            switch self {

            case .oneMonth:

                return "1 month"

            case .threeMonths:

                return "3 months"

            case .sixMonths:

                return "6 months"

            case .oneYear:

                return "1 year"

            }

        }

    }



    var body: some View {

        let spendingData = dataManager.spendingData(for: selectedTimeRange)



        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                // Time Range Picker

                Picker("Time Range", selection: $selectedTimeRange) {

                    ForEach(TimeRange.allCases, id: \.self) { range in

                        Text(range.rawValue)

                    }

                }

                .pickerStyle(.segmented)

                .padding(.horizontal)



                // Summary Cards

                HStack(spacing: 16) {

                    SummaryCard(title: "Total Spending", value: spendingData.totalSpending.toCurrency())

                    SummaryCard(title: "Avg. Monthly Spending", value: spendingData.averageMonthlySpending.toCurrency())

                    SummaryCard(title: "Top Category", value: spendingData.topCategory)

                }

                .padding(.horizontal)



                // Chart

                                                VStack(alignment: .leading) {

                                                    Text("Spending Chart")

                                                        .font(.headline)

                                

                                                    if spendingData.spendingByMonth.count > 1 {

                                                        SpendingLineChartView(spendingByMonth: spendingData.spendingByMonth)

                                                    } else {

                                                        SpendingBarChartView(spendingByCategory: spendingData.spendingByCategory)

                                                    }

                                                }

                                                .padding(.horizontal)



                // Category Breakdown

                VStack(alignment: .leading) {

                    Text("Top Spending Categories")

                        .font(.headline)

                    ForEach(spendingData.spendingByCategory) { categorySpending in

                        CategoryRow(category: categorySpending.category, amount: categorySpending.total, total: spendingData.totalSpending)

                    }

                }

                .padding(.horizontal)

            }

            .padding(.vertical)

        }

        .navigationTitle("Trends")

    }

}



struct CategoryRow: View {

    let category: TransactionCategory

    let amount: Double

    let total: Double



    var body: some View {

        HStack {

            Image(systemName: category.iconName)

                .font(.system(size: 20))

                .foregroundColor(category.tintColor)

                .frame(width: 30)

            Text(category.displayName)

            Spacer()

            Text(amount.toCurrency())

                .fontWeight(.semibold)

            ProgressView(value: amount, total: total)

                .frame(width: 100)

                .tint(category.tintColor)

        }

        .padding(.vertical, 4)

    }

}



struct SummaryCard: View {

    let title: String

    let value: String



    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)

                .font(.subheadline)

                .foregroundColor(.secondary)

            Text(value)

                .font(.title2)

                .fontWeight(.semibold)

        }

        .padding()

        .frame(maxWidth: .infinity, alignment: .leading)

        .background(Color(NSColor.controlBackgroundColor))

        .cornerRadius(8)

    }

}



extension Double {

    func toCurrency() -> String {

        let formatter = NumberFormatter()

        formatter.numberStyle = .currency

        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"

    }

}
