//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

//import SwiftUI
//
//struct HomeView: View {
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(DataManager.self) private var dataManager
//
//    @Binding var selectedYear: Int
//    @Binding var selectedMonth: Int
//
//    private let months: [String] = DateFormatter().monthSymbols
//
//    var body: some View {
//        // TODO: if these need too be this different, then break out into a separate file
//        if !isIPad {
//            ScrollView {
//                Grid(alignment: .top) {
//                    if !isIPad {
//                        GridRow {
////                            HeaderView(title: "Mula", selectedMonth: dataManager.selectedMonth)
//                        }
//                        .gridCellColumns(2)
//                    }
//
//                    tilesView
//
//                    categoriesView
//                }
//            }
//            .padding(.horizontal)
//    //        .navigationTitle("Mula")
//    //        .navigationBarTitleDisplayMode(.inline)
//            .navigationBarHidden(true)
//            .scrollIndicators(.hidden)
//        } else {
//            HStack(alignment: .top){
//                Grid {
//                    tilesView
//                }
//    
//                ScrollView {
//                    categoriesView
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//
//    var isIPad: Bool {
//        return horizontalSizeClass == .regular
//    }
//
////    public var incomeTotal: Double {
////        return dataManager.bucketTotalsForSelectedMonth[.income] ?? 0.0
////    }
//
//    var tilesView: some View {
//        Group {
//            GridRow {
//                // TODO: rename to TileBucketView
//                tileView(for: .fixed)
//
//                tileView(for: .spending)
//            }
//            
//            GridRow {
//                tileView(for: .saving)
//
//                tileView(for: .investment)
//            }
//
//            GridRow {
//                VStack {
//                    Text("Overview")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    ChartView(expenses: expensesForSelectedMonth)
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(backgroundCornerRadius)
//                .gridCellColumns(2)
//            }
//        }
//    }
//
//    var categoriesView: some View {
//        Group {
//            ForEach(Category.allCases) { category in
//                GridRow {
//                    let categoryTotal = dataManager.totalExpense(with: year, and: month, in: category)
//                    RowView(iconName: category.iconName, title: category.name, color: category.tintColor) {
//                        ExpenseAmountView(amount: categoryTotal)
//                    }
//                    .gridCellColumns(2)
//                }
//            }
//        }
//    }
//
//    func tileView(for bucket: Bucket) -> some View {
//        let total = dataManager.totalExpense(with: year, and: month, in: bucket) * -1
//        let budget = dataManager.budget(for: bucket)
//        return TileView(bucket: bucket, amount: total, budget: budget)
//    }
//
//    var year: String {
//        return String(selectedYear)
//    }
//
//    var month: String {
//        return months[selectedMonth-1]
//    }
//
//    public var expensesForSelectedMonth: [Expense] {
//        return dataManager.expenses(with: year, and: month)
//    }
//
////    private var amount: Double {
////        return (dataManager.bucketTotalsForSelectedMonth[bucket] ?? 0.0) * -1
////    }
//}

//#Preview {
//    HomeView(dataManager: DataManager.shared)
//}
