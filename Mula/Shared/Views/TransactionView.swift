//
//  TransactionView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct TransactionView: View {
    let transaction: Transaction
    let tint: Color
    let iconName: String

    init(transaction: Transaction) {
        self.transaction = transaction

        var tint = Bucket.income.tint
        var iconName = Bucket.income.icon
        if let expense = transaction as? Expense {
            tint = expense.category.tintColor
            iconName = expense.category.iconName
        }

        self.tint = tint
        self.iconName = iconName
    }

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 35, height: 35)

                Image(systemName: iconName)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(formatDate(transaction.date))
                    .font(.caption)
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(amountBackgroundColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(amountBackgroundColor.opacity(0.2))
                )
        }
        .padding(5)
    }

    private var amountBackgroundColor: Color {
        return transaction.amount < 0 ? .green : .red
    }

    private func formatDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date ?? Date())
    }
}
