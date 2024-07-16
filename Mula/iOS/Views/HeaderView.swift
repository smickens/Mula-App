//
//  HeaderView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/15/24.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var selectedMonth: String
    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text(month)
                }
            }
        }
    }
}

#Preview {
    HeaderView(title: "Mula", selectedMonth: .constant("March"))
}
