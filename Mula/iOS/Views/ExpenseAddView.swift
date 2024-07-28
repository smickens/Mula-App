//
//  TransactionAddView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

import SwiftUI

struct ExpenseAddView: View {
    @Environment(DataManager.self) private var dataManager
    @Bindable var expense: Expense

    var body: some View {
        ExpenseFormView(
            id: nil,
            title: $expense.title,
            amount: $expense.amount,
            date: $expense.date,
            bucket: $expense.bucket,
            category: $expense.category
        ) {
            dataManager.addExpense(expense: expense)
        }
    }
}
