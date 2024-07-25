//
//  TransactionView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct ExpenseView: View {
    @Bindable var expense: Expense

    var body: some View {
        TransactionView(
            title: expense.title,
            date: expense.date,
            amount: -expense.amount,
            tint: expense.category.tintColor,
            iconName: expense.category.iconName
        )
    }
}

struct IncomeView: View {
    @Bindable var income: Income

    var body: some View {
        TransactionView(
            title: income.title,
            date: income.date,
            amount: income.amount,
            tint: Bucket.income.tint,
            iconName: Bucket.income.icon
        )
    }
}

struct TransactionView: View {
    let title: String
    let date: Date
    let amount: Double
    let tint: Color
    let iconName: String

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
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text(formatDate(date))
                    .font(.caption)
            }

            Spacer()

            Text(amount, format: .currency(code: "USD"))
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
        return amount > 0 ? .green : .red
    }

    private func formatDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date ?? Date())
    }
}
