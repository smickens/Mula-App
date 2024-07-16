//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedMonth: String = Date().month

    @State private var fixed: Double
    @State private var spending: Double
    @State private var saving: Double
    @State private var investment: Double

    init() {
        fixed = DataManager.shared.total(for: Date().month, in: .fixed)
        spending = DataManager.shared.total(for: Date().month, in: .spending)
        saving = DataManager.shared.total(for: Date().month, in: .saving)
        investment = DataManager.shared.total(for: Date().month, in: .investment)
    }

    var body: some View {
        ScrollView {
            HeaderView(title: "Mula", selectedMonth: $selectedMonth)

            Grid {
                GridRow {
                    TileView(title: "Fixed", icon: "grid", tint: .cyan, amount: $fixed)

                    TileView(title: "Spending", icon: "tag.fill", tint: .pink, amount: $spending)
                }

                GridRow {
                    TileView(title: "Savings", icon: "bolt.fill", tint: .green, amount: $saving)

                    TileView(title: "Investments", icon: "hourglass", tint: .indigo, amount: $investment)
                }

                GridRow {
                    RoundedRectangle(cornerRadius: 10.0)
                        .gridCellColumns(2)
                        .frame(height: 170.0)
                        .foregroundStyle(.secondary.opacity(0.1))
                }
            }

//                    Text("Overview")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top)
        }
        .padding()
//                .navigationTitle("Mula")
        .navigationBarHidden(true)
//                .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .onChange(of: selectedMonth) { _, newValue in
            fixed = DataManager.shared.total(for: selectedMonth, in: .fixed)
            spending = DataManager.shared.total(for: selectedMonth, in: .spending)
            saving = DataManager.shared.total(for: selectedMonth, in: .saving)
            investment = DataManager.shared.total(for: selectedMonth, in: .investment)
        }
    }

    
}

#Preview {
    HomeView()
}
