//
//  HomeView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedMonth: String = Date().month

    let months: [String] = DateFormatter().monthSymbols
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Mula")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text(month)
                    }
                }
            }

            Grid {
                GridRow {
                    TileView(title: "Fixed", icon: "grid", tint: .cyan)

                    TileView(title: "Spending", icon: "tag.fill", tint: .pink)
                }

                GridRow {
                    TileView(title: "Savings", icon: "bolt.fill", tint: .green)

                    TileView(title: "Investments", icon: "hourglass", tint: .indigo)
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
    }
}

#Preview {
    HomeView()
}
