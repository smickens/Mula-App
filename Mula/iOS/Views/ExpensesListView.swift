//
//  ExpensesListView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ExpensesListView: View {
    @Environment(DataManager.self) private var dataManager
    var expenses: [Expense]
    @Binding var expenseToEdit: Expense?
    var deleteAction: (Expense) -> Void

    var body: some View {
        List(expenses, id: \.id) { expense in
            ExpenseView(expense: expense)
                .expenseSwipeActions {
                    expenseToEdit = expense
                } onDelete: {
                    deleteAction(expense)
                }
        }
        .listStyle(.plain)
        .listItemTint(Color(.systemGray6))
    }
}
