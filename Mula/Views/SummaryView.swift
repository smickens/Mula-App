//
//  SummaryView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct SummaryView: View {
    let totalMoneyIn: Double
    let totalMoneyOut: Double
    let totalsByCategory: [Category: Double]

    var body: some View {
        VStack {
            Spacer()

            Text("Spending Overview")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom)

            HStack {
                Spacer()

                Grid(horizontalSpacing: 10, verticalSpacing: 5) {
                    GridRow {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30, weight: .semibold))

                        Text("+")

                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 30, weight: .semibold))

                        Text("=")

                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    GridRow {
                        Text(totalMoneyIn, format: .currency(code: "USD"))

                        Text("+")

                        Text(totalMoneyOut, format: .currency(code: "USD"))

                        Text("=")

                        Text(totalMoneyIn + totalMoneyOut, format: .currency(code: "USD"))
                    }
                }
                .foregroundStyle(.gray)

                Spacer()
            }
            .padding(.bottom)

            Spacer()

            Text("Category Totals")
                .font(.title3)
                .fontWeight(.semibold)

            PieChartView(totals: totalsByCategory.map { $0.value }, categories: totalsByCategory.map { $0.key })
                .frame(width: 160, height: 160)

            VStack(alignment: .leading) {
                LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading, spacing: 5) {
                    ForEach(Category.allCases, id: \.self) { category in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(category.tintColor)
                                    .frame(width: 28, height: 28)

                                category.icon
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", totalsByCategory[category] ?? 0.0))")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }

            Spacer()
        }
    }
}

