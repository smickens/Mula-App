//
//  TransactionView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct TransactionView: View {
    let expense: Expense

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(expense.bucket.tint)
                    .frame(width: 35, height: 35)

                Image(systemName: expense.category.iconName)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading) {
                Text(expense.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(formatDate(expense.date))
                    .font(.caption)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(expenseColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(expenseColor.opacity(0.2))
                )
        }
        .padding(5)
    }

    private var expenseColor: Color {
        return expense.amount < 0 ? .green : .red
    }

    private func formatDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date ?? Date())
    }
}
