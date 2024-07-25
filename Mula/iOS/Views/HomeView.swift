//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @Environment(DataManager.self) private var dataManger
    @Binding var selectedMonth: String

    var body: some View {
        ScrollView {
            Grid(alignment: .top) {
                GridRow {
                    HeaderView(title: "Mula", selectedMonth: $selectedMonth)
                }
                .gridCellColumns(2)

                GridRow {
                    TileView(bucket: .fixed)

                    TileView(bucket: .spending)
                }

                GridRow {
                    TileView(bucket: .saving)

                    TileView(bucket: .investment)
                }

                GridRow {
                    VStack {
                        Text("Overview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ChartView(transactions: dataManger.transactionsForSelectedMonth)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(backgroundCornerRadius)
                    .gridCellColumns(2)
                }

                GridRow {
                    RowView(iconName: "arrow.up", title: "Income:", color: .green) {
                        Text(incomeTotal, format: .currency(code: "USD"))
                            .font(.body)
                    }
                    .gridCellColumns(2)
                }

                ForEach(Category.allCases) { category in
                    GridRow {
                        RowView(iconName: category.iconName, title: category.name, color: category.tintColor) {
                            Text(dataManger.categoryTotalsForSelectedMonth[category] ?? 0.0, format: .currency(code: "USD"))
                                .font(.body)
                        }
                        .gridCellColumns(2)
                    }
                }
            }
        }
        .padding()
//        .navigationTitle("Mula")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .scrollIndicators(.hidden)
    }

    public var incomeTotal: Double {
        return dataManger.bucketTotalsForSelectedMonth[.income] ?? 0.0
    }
}

#Preview {
    HomeView(selectedMonth: .constant("May"))
}
