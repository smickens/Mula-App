//
//  ExpenseEditView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

import SwiftUI

struct ExpenseEditView: View {
    @Environment(DataManager.self) private var dataManager
    @Bindable var expense: Expense

    var body: some View {
        ExpenseFormView(
            id: expense.id,
            title: $expense.title,
            amount: $expense.amount,
            date: $expense.date,
            bucket: $expense.bucket,
            category: $expense.category
        ) {
            dataManager.updateExpense(expense: expense)
        }
    }
}
