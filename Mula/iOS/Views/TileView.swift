//
//  TileView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI
import Charts

struct TileView: View {
    let title: String
    let icon: String
    let tint: Color
    @Binding var amount: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(.secondary).opacity(0.1)

            VStack {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                ZStack {
                    Chart {
                        SectorMark(
                            angle: .value("Total", 1.0),
                            innerRadius: .ratio(0.85)
                        )
                        .foregroundStyle(.gray).opacity(0.4)

                        SectorMark(
                            angle: .value("Total", 0.5),
                            innerRadius: .ratio(0.85)
                        )
                        .foregroundStyle(tint)
                    }
                    .chartLegend(.hidden)


                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(tint)
                }
                .padding(10)

                Text("$\(Int(amount))").font(.subheadline).fontWeight(.semibold) + Text(" / ").foregroundStyle(.secondary) + Text("$1250").font(.subheadline).foregroundStyle(.secondary)
            }
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

//#Preview {
//    Grid {
//        GridRow {
//            TileView(title: "Fixed", icon: "grid", tint: .cyan)
//
//            TileView(title: "Spending", icon: "tag.fill", tint: .pink)
//        }
//
//        GridRow {
//            TileView(title: "Savings", icon: "bolt.fill", tint: .green)
//
//            TileView(title: "Investments", icon: "hourglass", tint: .indigo)
//        }
//    }
//    .padding()
//}
