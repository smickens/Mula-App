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
            RowView(iconName: "doc.text", title: "Title:", color: .purple, text: transaction.title)

            RowView(iconName: "dollarsign.circle", title: "Amount:", color: .green, value: transaction.amount)

            RowView(iconName: "calendar", title: "Date:", color: .blue, text: transaction.date.description)

            if let expense = transaction as? Expense {
                RowView(iconName: "tag", title: "Category:", color: .orange, text: expense.category.name)
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
