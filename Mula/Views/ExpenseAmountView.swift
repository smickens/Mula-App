//
//  ExpenseAmountView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/31/24.
//

import SwiftUI

struct ExpenseAmountView: View {
    let amount: Double

    var body: some View {
        Text(amount, format: .currency(code: "USD"))
            .font(.headline)
            .foregroundStyle(amountColor)
            .fontWeight(.medium)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(amountColor.opacity(0.2))
            )
    }

    private var amountColor: Color {
        if amount == 0 {
            return .gray
        }
        return amount > 0 ? .green : .red
    }
}

#Preview {
    ExpenseAmountView(amount: 10.0)
}
