//
//  TileView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/7/24.
//

import SwiftUI
import Charts

struct TileView: View {
    @Environment(DataManager.self) private var dataManger
    let bucket: Bucket

    var body: some View {
        VStack {
            Text(bucket.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            ZStack {
                Chart {
                    SectorMark(
                        angle: .value("Background", amount < budget ? (1 - amount / budget) : 0.0),
                        innerRadius: .ratio(0.85)
                    )
                    .foregroundStyle(.gray).opacity(0.4)

                    SectorMark(
                        angle: .value("Amount", amount / budget),
                        innerRadius: .ratio(0.85)
                    )
                    .foregroundStyle(bucket.tint)
                }
                .chartLegend(.hidden)


                Image(systemName: bucket.icon)
                    .font(.title2)
                    .foregroundStyle(bucket.tint)
            }
            .padding(10)

            Text("$\(Int(amount))").font(.subheadline).fontWeight(.semibold).foregroundStyle(amount > budget ? .red : .primary) + Text(" / ").foregroundStyle(.secondary) + Text("$\(Int(budget))").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
        .aspectRatio(1, contentMode: .fit)
        .background(Color(.systemGray6))
        .cornerRadius(backgroundCornerRadius)
    }

    private var amount: Double {
        return (dataManger.bucketTotalsForSelectedMonth[bucket] ?? 0.0) * -1
    }

    private var budget: Double {
        return 1500.0
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
