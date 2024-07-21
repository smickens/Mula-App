//
//  TransactionEditView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct TransactionEditView: View {
    let transaction: Transaction

    var body: some View {
        VStack {
            Text("Details")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            RowView(iconName: "doc.text", title: "Title:", color: .purple) {
                Text(transaction.title)
                    .font(.body)
            }

            RowView(iconName: "dollarsign.circle", title: "Amount:", color: .green) {
                Text(transaction.amount, format: .currency(code: "USD"))
                    .font(.body)
            }

            RowView(iconName: "calendar", title: "Date:", color: .blue) {
                Text(transaction.date.description)
                    .font(.body)
            }

            if let expense = transaction as? Expense {
                RowView(iconName: "tag", title: "Category:", color: .orange) {
                    Text(expense.category.name)
                        .font(.body)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Details")
    }
}

#Preview {
    NavigationView {
        TransactionEditView(transaction: Expense(id: "some_id", title: "Popeyes", date: Date(), amount: 15.62, bucket: .spending, category: .eatingOut))
    }
}
