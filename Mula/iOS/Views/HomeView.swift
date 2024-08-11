//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @Bindable var dataManager: DataManager

    var body: some View {
        ScrollView {
            Grid(alignment: .top) {
                GridRow {
                    HeaderView(title: "Mula", selectedMonth: $dataManager.selectedMonth)
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

                        ChartView(expenses: dataManager.expensesForSelectedMonth)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(backgroundCornerRadius)
                    .gridCellColumns(2)
                }

                ForEach(Category.allCases) { category in
                    GridRow {
                        RowView(iconName: category.iconName, title: category.name, color: category.tintColor) {
                            ExpenseAmountView(amount: dataManager.categoryTotalsForSelectedMonth[category] ?? 0.0)
                        }
                        .gridCellColumns(2)
                    }
                }
            }
        }
        .padding(.horizontal)
//        .navigationTitle("Mula")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .scrollIndicators(.hidden)
    }

    public var incomeTotal: Double {
        return dataManager.bucketTotalsForSelectedMonth[.income] ?? 0.0
    }
}

#Preview {
    HomeView(dataManager: DataManager.shared)
}
